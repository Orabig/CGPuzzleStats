<?php

//**********************************************************************
//
// Accès aux pages de leaderboard complètes (qui donnent des indication
// non disponibles dans d'autres API)
//
// C'est totalement overkill, on est d'accord, mais c'est en attendant
// d'avoir des API CG plus efficaces (comme suggéré par [CG]Rickroll)
//
//**********************************************************************

//
// Return an object like   { "playerID" => { "LANG1"=>"Score1", ...}, ...}
//
function loadScoreByPlayerByLang($cache, $puzzleName) {
	# Si le navigateur de l'utilisateur n'est pas en français, alors on lit le fichier anglais
	$lang = substr($_SERVER['HTTP_ACCEPT_LANGUAGE'], 0, 2);
	if ($lang!='fr') {
		$lang='en';
	}
	# curl -X POST '' -d '["temperatures-codesize","","global"]'
	
	global $EXPIRATION_H;
	$API='https://www.codingame.com/services/LeaderboardsRemoteService/getPuzzleLeaderboard';
	$EXPIRATION = 1+$EXPIRATION_H * 60 * 60;
	$KEY="leaderboard-$puzzleName";
	$scoreByLang = $cache->retrieve($KEY); 

	if (! $scoreByLang) {
		$result = POST($API, "[$puzzleName,\"\",\"global\"]");
		if ($result === FALSE) { ?> <h1>CG API Error</h1> <? return; }
		$dec = json_decode($result);
		if (!$dec->{'success'}) { ?> <h1>CG API Error</h1> <? return; }
		
		// La structure complexe doit être décodée (playerID -> ['LANG'->score])
	
	// object (3) {
	//  ["users"]=>
	//  array(1983) {
	// 	 	[0]=>
	// 	 	object (13) {
	// 	 	["pseudo"]=>
	// 	 	string(16) "FredericBautista"
	// 	 	(...)
	// 	 	["programmingLanguage"]=>
	// 	 	string(3) "C++"
	// 	 	["inProgress"]=>
	// 	 	bool(false)
	// 	 	["reportEnabled"]=>
	// 	 	bool(true)
	// 	 	["criteriaScore"]=>
	// 	 	float(2509)
	//      (...)
	// 	 	["codingamer"]=>
	// 	 	object (12) {
	// 	 	["userId"]=>
	// 	 	int(1327028)
	// 	 	(...)

		$scoreByLang = new StdClass;
		
		foreach($dec->{'success'}->{'users'} as $result) {
			$playerID = $result->{'codingamer'}->{'userId'};
			$langage = $result->{'programmingLanguage'};
			$score = $result->{'criteriaScore'};
			if (!$scoreByLang->{$playerID}) $scoreByLang->{$playerID} = new StdClass;
			$scoreByLang->{$playerID}->{$langage} = $score;
		}

		$cache->store($KEY,$scoreByLang,$EXPIRATION);
	}
	return $scoreByLang;
}