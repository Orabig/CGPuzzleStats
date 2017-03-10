<?php

//**********************************************************************
//
// Fonctions de manipulation des puzzles
//
// displayPuzzleTable( $caches, $LVL, $jIds, $COLS ) : Affiche la table
//
//**********************************************************************

function loadPuzzles() {
	# Si le navigateur de l'utilisateur n'est pas en français, alors on lit le fichier anglais
	$lang = substr($_SERVER['HTTP_ACCEPT_LANGUAGE'], 0, 2);
	if ($lang!='fr') {
		$lang='en';
	}
	# TODO : Tenter un chargement dynamique avec connexion privée
	# Ce fichier a été téléchargé à la main (avec ma connexion) et déposé sur le serveur
	$string = file_get_contents("const/findGamesPuzzleProgress.json.$lang");
	if ($string) {
		return json_decode($string)->{"success"};
	} else {
		?><h1>Fichier 'puzzles' manquant</h1><?
	}
}

# Avec le tableau des achievements du joueur, on détermine si le puzzle passé en paramètre
# possède au moins un achievement associé
# Renvoie le taux de complétion du puzzle (entre 0 et 100) PLUS l'age en jour << 10
# ou false s'il n'existe pas d'achievement pour ce puzzle
function getPuzzleSolved($achievements, $puzzle) { 
	$puzzleId = $puzzle->{"id"};
	# Erreur de CG !
	if ($puzzleId==55) {$puzzleId=53;}
	if ($puzzleId==54) {$puzzleId=52;}
	if ($puzzleId==121) {$puzzleId=3;}
	# On cherche les "id" de la forme "PZ_ddP_P123"
	$max=0;
	$ageBest=0; # L'age du meilleur achievement pour ce puzzle
	$exist=false;
	foreach($achievements as $achievement) {
		# $achievements = object (14) {
		#	["id"]=>
		#	string(10) "PZ_100P_P1"
		#	["puzzleId"]=>
		#	int(0)
		#	["title"]=>
		#	string(34) "100% Skynet Revolution - Episode 1"
		#	["description"]=>
		#	string(59) "Reach a 100% score on Skynet Revolution - Episode 1 puzzle."
		#	["points"]=>
		#	int(50)
		#	["progress"]=>
		#	int(1)
		#	["progressMax"]=>
		#	int(1)
		#	["completionTime"]=>
		#	int(1421198974000)
		#	["imageBinaryId"]=>
		#	int(1924859513890)
		#	["categoryId"]=>
		#	string(13) "puzzle-medium"
		#	["groupId"]=>
		#	string(20) "puzzle-medium-skynet"
		#	["level"]=>
		#	string(6) "SILVER"
		#	["unlockText"]=>
		#	string(10) "reach 100%"
		#	["weight"]=>
		#	float(8400)
		#	}
		$id=$achievement->{'id'};
		if (preg_match( "/PZ_(\d+)P_P$puzzleId$/", $id, $groups)) { 
			$exist=true;
			$progress=$achievement->{'progress'};
			if ($progress>0){
				$time=intval($achievement->{'completionTime'} / 1000);
				$now=time();
				$age = $now-$time;
				# Computes the age of the achievement in days 
				$age = $age / (60 * 60 * 24);
				$per=$groups[1];
				if ($per>$max) {
					$max=$per;
					$ageBest=$age;
					}
			}
		}
	}
	return $exist ? ( $max + ($ageBest << 10)) : false;
}

# Permet de savoir si un puzzle a été résolu par le joueur. Comme ce test est basé sur les achievements,
# dans le cas où le puzzle n'a pas d'achievement associé, alors on répond true, dans le doute.
function isPuzzleSolved($achievements, $puzzle) { 
	$percent = getPuzzleSolved($achievements, $puzzle);
	if ($percent===false) { return true; }
	return $percent>0;
}

#
# CHARGE le puzzle ID:$ID
#
# renvoie un tableau de { ["id"]=>"Bash"    ["solved"]=>false    ["last"]=>false    ["onboarding"]=>false  }
#
function loadPuzzle( $cache, $joueurID, $ID ) {
	global $EXPIRATION_H;
	$API='https://www.codingame.com/services/PuzzleRemoteService/findAvailableProgrammingLanguages';
	$EXPIRATION = 1+$EXPIRATION_H * 60 * 60;
	$KEY="findGamesPuzzleProgress-$ID";
	$dec = $cache->retrieve($KEY); // Le fichier de cache contient toutes les infos liées à un joueur, et la clé indique le résultat pour le puzzle en question.

	if (! $dec) {
		// var_dump_pre("load Puzzle $joueurID, $ID");
		# <h1>LOADING (TODO)</h1>
		$result = POST($API, "[$ID, $joueurID]");
		if ($result === FALSE) { ?> <h1>CG API Error</h1> <? }
		# var_dump( $result );
		$dec = json_decode($result);
		$cache->store($KEY,$dec,$EXPIRATION);
	}
	
	// un Array d'objet pour chacun des 25 langages : 
	//  { ["id"]=>"Bash"    ["solved"]=>false    ["last"]=>false    ["onboarding"]=>false  }
	//error_log("\nPUZZLE=".var_dump_ret($dec->{'success'}));
	
	return $dec->{'success'};
}

function computeUsedLangages($caches, $achievements, $PUZZLES, $LEVEL, $joueursID) {
	$langUsed = array();
	foreach ($PUZZLES as $puzzle) {	
		if ($puzzle->{"level"}==$LEVEL) { # On cherche tous les puzzle de la catégorie
			$ID=$puzzle->{"id"};
			foreach ($joueursID as $joueurID) {
				# Optimisation : on vérifie si le joueur a résolu (même partiellement) ce puzzle, car
				# dans le cas contraire, c'est inutile d'appeler loadPuzzle pour rien
				 if ( isPuzzleSolved($achievements[$joueurID], $puzzle)) {
					$result = loadPuzzle($caches[$joueurID],$joueurID,$ID);
					foreach ($result as $lang) { 
						$langId = $lang->{"id"};
						if (! in_array($langId, $langUsed)) {
							if ($lang->{"solved"}) { # Et pour ceux qui ont été résolus par au moins un joueur
								$langUsed[] = $langId;
							}
						}
					}
				 } 
			}
		}
	}
	sort($langUsed);
	return $langUsed;
}

#
# CHARGE tous les achievements d'un joueur
#

function loadAchievements( $cache, $joueurID ) {
	global $EXPIRATION_H;
	$EXPIRATION = $EXPIRATION_H * 60 * 60;
	$KEY="achievements";
	$dec = $cache->retrieve($KEY); 

	# Si la clé existe dans le cache, on retourne la valeur
	if ($dec) {
		return $dec->{'success'};
	}
	# Sinon, on fait la requête sur l'API
	$API='https://www.codingame.com/services/AchievementRemoteService/findByCodingamerId';
	$result = POST($API, "[$joueurID]");
	if ($result === FALSE) { ?> <h1>CG API Error</h1> <? }
	else {
		$dec = json_decode($result);
		$cache->store($KEY,$dec,$EXPIRATION);
		return $dec->{'success'};
	}
}


function displayPuzzleTable( $caches, $LEVEL, $joueursID, $COLORS ) {
	if (!$LEVEL) { ?><h5 class="choose_level">Select a difficulty (Easy/Medium/...)</h5><? return;}
	
		$PUZZLES=loadPuzzles();
		
		foreach ($joueursID as $joueurID) {
			$achievements[$joueurID] = loadAchievements($caches[$joueurID], $joueurID);
		}

		$langUsed = computeUsedLangages($caches, $achievements, $PUZZLES, $LEVEL, $joueursID);

		# La pagination des langages
		$PAGE=$_GET["p"]; if (!$PAGE) {$PAGE=1;}
		if (count($langUsed)<=19) {$PAGENUM=1;}else {$PAGENUM=2;}
		if ($PAGE>$PAGENUM) { $PAGE=$PAGENUM; }
		display_pager($PAGE,$PAGENUM);
		
		# Calcule les langes à afficher
		$cols = pagination_slice($langUsed,$PAGE,$PAGENUM);

		// --------------------- AFFICHE LA PREMIERE LIGNE (Langages) ---------------
		?><table class="main-table table table-striped table-header-rotated"><thead><tr>
		<th class="table-header color-legend" colspan="2">
		<span class="day-legend hover-legend"><span class="glyphicon glyphicon-ok-sign legend-grey new-progress-day"></span><small>Today</small></span>
		<span class="week-legend hover-legend"><span class="glyphicon glyphicon-ok-sign legend-grey new-progress-week"></span><small>Last week</small></span>
		<span class="month-legend hover-legend"><span class="glyphicon glyphicon-ok-sign legend-grey new-progress"></span><small>Last month</small></span>
		</th><?
		
		$langCount=count($cols);
		if ($langCount>0) {
			foreach ($cols as $langId) {
				?><th class="rotate-45"><div><span><?= $langId ?></span></div></th><?
				$column_count++;
			}
		} else {
			?><th class="rotate-45"><div><span>(None solved)</span></div></th><?
		}
		?></tr></thead><tbody><?
		
		$globalCache = getGlobalCacheFile();
		
		// --------------------- AFFICHE LES LIGNES SUIVANTES (Puzzles) ---------------					
		foreach ($PUZZLES as $puzzle) {	
			if ($puzzle->{"level"}==$LEVEL) { # FILTRE : on affiche uniquement le niveau demandé
				$ID=$puzzle->{"id"};
				$TITLE=$puzzle->{"title"};
				$LEADERBOARD_ID=$puzzle->{"puzzleLeaderboardId"};
				$URL="http://www.codingame.com" . $puzzle->{"detailsPageUrl"};

				// Chargement des infos spécifiques au golf et optimisation
				$detailledScoreByPlayer = loadScoreByPlayerByLang($globalCache,$LEADERBOARD_ID);
				
				$lastKnownResult =array();
				# Chargement des résultats des joueurs
				foreach ($joueursID as $jID) {
					if ( isPuzzleSolved($achievements[$jID], $puzzle)) {
						$puzzleResults[$jID] = loadPuzzle($caches[$jID],$jID,$ID);
						$detailledScore[$jID] = $detailledScoreByPlayer->{$jID};
						$lastKnownResult = $puzzleResults[$jID];
					}
				}
				
				# Contient un tableau dont les langages sont dans le même ordre que tous les $puzzleResults
				$langOrder =  array_map(function($e) {
						return is_object($e) ? $e->id : $e['id'];
					}, $lastKnownResult);
				
				# $puzzleResults = array [   { ["id"]=>"Bash"    ["solved"]=>false    ["last"]=>false    ["onboarding"]=>false  } .... ]
				
				# -------------------------   AFFICHAGE DE LA LIGNE DE PUZZLE
				?><tr><th class="percent" width="<?= 10 + 20 * (count($joueursID)) ?>px"><?
				
				# Réussite de chaque joueur
				$i=0;
				foreach ($joueursID as $jID) {
					$name=getPlayerPseudo($jID);
					$color=$COLORS[$i];$i++;
					$percentAge = getPuzzleSolved($achievements[$jID], $puzzle);
					$percent=$percentAge & 0xFF;
					$age=$percentAge >> 10;
					# Add 'new-progress' class for puzzles younger than 30 days
					$new = $age<2 ? 'new-progress-day' :( $age<8 ? 'new-progress-week' :( $age<31 ? 'new-progress' : ''));
					$at = $age==1 ? 'yesterday' : 
							( $age<30 ? "$age days ago" : 
							( $age<60 ? "1 month ago" : 
							( $age<365 ? (intval($age/30) . " months ago") : 
							(intval($age/365) . " year".($age<365*2?"":"s")." ago") )));
					if ( $percent==100) {
						?><span class="touched glyphicon glyphicon-ok-sign <?=$color?> <?=$new?>" data-toggle="tooltip" title="Solved <?= $at ?>"></span><?
					} else 
					if ( $percent>0) {
						?><span class="touched glyphicon glyphicon-unchecked half <?=$color?> <?=$new?>" data-toggle="tooltip"  title="<?= $percent ?>% solved <?= $at ?>"></span><?
					} else
					if ( $percentAge===false ) {
						# No achievement for this puzzle, so display nothing
					} else {
						?><span class="glyphicon glyphicon-remove-circle <?=$color?>"></span><?
						}
				}
				
				# Nom du puzzle
				?></th><th class="row-header"><a href="<?=$URL?>" target="_new"><?= $TITLE ?></a></th><?
				
				# NOTE : OK, c'est pas terrible, mais ca marche. J'utilise $result[$jID] en dehors de toute boucle sur $jID
				# car tous les tableaux ont la même structure, et j'utilise donc là le dernier jID rencontré.
				
				# Valeurs pour chaque colonne
				foreach ($cols as $langId) { 
					# On recherche dans $langOrder l'indice $c qui correspond à la colonne $langId
					$c=array_search($langId, $langOrder);
					if($c === false && count($lastKnownResult)>0) {
						# le langage n'est pas représenté pour ce puzzle
						?><td class="danger"></td><?
					} else {
						?><td><?
						$countResult=0;
						$i=0;
						foreach ($joueursID as $jID) {
							$color=$COLORS[$i];$i++;
							# Si le joueur a ce puzzle, on affiche son badge
							if ( isPuzzleSolved($achievements[$jID], $puzzle) && $puzzleResults[$jID][$c]->{"solved"}) {
								if ($detailledScore[$jID]->{$langId}) {
									# S'il existe un score (codegolf ou optim) on l'affiche
									# Dans le cas d'un puzzle normal, on affiche une coche
									?><span class="score <?=$color?>"><?= $detailledScore[$jID]->{$langId} ?></span><? 
								} else {
									# Dans le cas d'un puzzle normal, on affiche une coche
									?><span class="glyphicon glyphicon-ok <?=$color?>"></span><? 
								}
								$countResult++;
							} 
						}
						# Si aucun des joueurs n'a ce puzzle, on remplit la case
						if ($countResult==0) {
							?>-<?
						}
						
						?></td><?
					}
				}
				
				?></tr><?
			} // if puzzle==LEVEL
		} // foreach PUZZLES
}
	