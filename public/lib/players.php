<?php

//**********************************************************************
//
// Fonctions de manipulation des utilisateurs
//
// searchPlayerByPseudo ( $pseudo )     : Retourne la liste des utilisateurs connus
// getPlayerPseudo( $jId )              : Renvoie le pseudo de l'utilisateur (sauvé au moment de la recherche)
// getPlayerBlockOutput( $list )        : Renvoie une liste de joueur en HTML (résultat de recherche)
// getPlayerLegendOutput( $pIds, $cols ): Renvoie une liste de joueur en HTML (légendes colorées)
// createPlayerCacheFile ($pId)         : Renvoie le fichier de cache du joueur
//
//**********************************************************************


	#
	# CHERCHE une liste de joueur avec un pseudo : renvoie un tableau de candidats
	#
	function searchPlayerByPseudo( $pseudo ) {
		$API='https://www.codingame.com/services/LeaderboardsRemoteService/getGlobalLeaderboard';
		$data = "[1,{\"keyword\":\"$pseudo\"},\"\",true,\"global\"]";

		// use key 'http' even if you send the request to https://...
		$options = array(
			'http' => array(
				'header'  => "Content-type: application/x-www-form-urlencoded\r\n",
				'method'  => 'POST',
				'content' => $data
			)
		);
		$context  = stream_context_create($options);
		$result = file_get_contents($API, false, $context);
		if ($result === FALSE) { ?> <h1>CG API Error [searchPlayerByPseudo]</h1> <? }
		$dec = json_decode($result);
		$players = $dec->{'success'}->{'users'};
		foreach ($players as $player) {
			$pseudo=$player->{'pseudo'};
			$userId=$player->{'codingamer'}->{'userId'};
			file_put_contents( "../users/user.$userId", "$pseudo" );
		}
		return $players;
	}
	
	#
	# Le pseudo a été sauvé dans un fichier lors de la recherche
	#
	function getPlayerPseudo ( $jid ) {
	  global $PSEUDO;
	  if ($PSEUDO[$jid]) { return $PSEUDO[$jid]; }
	  // TODO : tester l'existence du fichier (si le fichier n'existe pas, alors l'ID 
	  // du joueur a été mise à la main dans l'url sans passer par la recherche. Il faut
	  // revenir à la page principale dans ce cas )
	  $result = file_get_contents("../users/user.$jid");
	  $PSEUDO[$jid]=$result;
	  return $result;
	}
	
	#
	# renvoie une liste de joueur en HTML (block de résultat de recherche)
	#  - $players est un tableau contenant 'pseudo', 'rank' et 'codingamer.userId'
	#
	function getPlayerBlockOutput( $players ) {
		$resultOutput=array();
		foreach ($players as $player) {
			$pseudo=$player->{'pseudo'};
			$rank=$player->{'rank'};
			$userId=$player->{'codingamer'}->{'userId'};
			$resultOutput[] = '<a pid="'. $userId .'" class="btn btn-primary btn-lg player search-player-result"> <span class="badge">#'. $rank .'</span> '.$pseudo.'</a>';
		}
		return $resultOutput;
	}
	#
	# renvoie une liste de joueur en HTML (Légendes colorées)
	#  - $playerIds est un tableau d'IDs
	#  - $colors est le tableau des codes CSS couleurs (red, green, ...)
	#
	function getPlayerLegendOutput( $playerIds, $colors ) {
		$resultOutput=array();
		$i=0;
		foreach ($playerIds as $joueurID) {
			$pseudo = getPlayerPseudo( $joueurID );
			$span = '<span class="legend-'. $colors[$i] .' legend-player">'.  $pseudo .'</span>';
			if (count($playerIds)>1) {
				$span .= '<button pid="'. $joueurID .'" type="button" class="btn btn-danger btn-xs btn-round remove-player"><span class="glyphicon glyphicon-remove"></span>';
			}
			$span .= '</button>';
			$resultOutput[] = $span;
			$i++;
		}
		return $resultOutput;
	}
	
	function createPlayerCacheFile( $playerId ) {
		$cache = new Cache("player-$playerId");
		$cache->setCachePath('../cache/');
		$cache->eraseExpired();
		return $cache;
	}
?>