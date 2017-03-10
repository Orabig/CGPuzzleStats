<?php

//**********************************************************************
//
// Fonctions utilitaires
//
// var_dump_ret ( $var )             : Renvoie le DUMP d'une variable
// var_dump_pre ( $var )             : Comme var_dump, mais dans un <pre>...</pre>
// POST( $URL, $data )               : Effectue une requete POST et renvoie le résultat (ou false en cas d'erreur)
//
// ********* Fonctions de pagination : $N est le nombre d'élément qu'on veut caser dans une page
// pagination_slice($array, $P, $N)  : Extrait une portion de tableau en fonction de la page en cours
// slice_count($array,$N)            : Retourne le nombre de page nécessaires pour afficher le tableau
// display_pager($P, $N)             : Affiche des onglets pour les pages 1..P..N
//**********************************************************************
	

function var_dump_ret($mixed = null) {
  ob_start();
  var_dump($mixed);
  $content = ob_get_contents();
  ob_end_clean();
  return $content;
}

function var_dump_pre($mixed = null) {
  echo "<pre>";
  var_dump($mixed);
  echo "</pre>";
}



function POST( $URL, $load ) {
	// use key 'http' even if you send the request to https://...
	$options = array(
		'http' => array(
			'header'  => "Content-type: application/x-www-form-urlencoded\r\n",
			'method'  => 'POST',
			'content' => $load
		)
	);
	$context  = stream_context_create($options);
	return file_get_contents($URL, false, $context);
}

#
# Extrait une portion de tableau en fonction de la page en cours
#
function pagination_slice($array,$PAGE,$NUMPAGE) {
	$PERPAGE = slice_count($array,$NUMPAGE);
	return array_slice($array,($PAGE-1)*$PERPAGE,$PERPAGE);
}
#
# Le nombre de colonne dans une page
#
function slice_count($array,$NUMPAGE) {
	return ceil(count($array)/$NUMPAGE);
}

function display_pager($PAGE,$PAGENUM) {		
	if ($PAGENUM>1) {
		?>
			<ul class="pagination pull-right">
			<?
			for($page=1;$page<=$PAGENUM;$page++) {
				?>
				<li id="<?=$page?>"<? if ($PAGE==$page ) {?> class="active"<?}?>><a href="#"><?=$page?></a></li>
				<?
			}
			?>
			</ul>
		<?
	}
}

$GLOBAL_CACHE;
function getGlobalCacheFile( ) {
	global $GLOBAL_CACHE;
	if (! $GLOBAL_CACHE) {
		$cache = new Cache("global");
		$cache->setCachePath('../cache/');
		$cache->eraseExpired();
		$GLOBAL_CACHE=$cache;
	}
	return $GLOBAL_CACHE;
}

?>
