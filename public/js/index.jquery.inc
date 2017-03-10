
<script>

	$('#levels a').on('click', function(event) {
		event.preventDefault();
		var level = event.target.id;
		setLevel(level);
		});
		
	if ($.query.get("level")) {
		$('#levels #'+$.query.get("level")).addClass('active');
	}

	$('.pagination li a').on('click', function(event) {
		event.preventDefault();
		var page = event.target.parentElement.id;
		setPage(page);
		});
		
	$('#add-player').on('click',  function(event) {
		setAdd();
		});
		
	$('#search').submit(function(event) {
		event.preventDefault();
		setSearch();
		});
		
	$('.search-player-result').on('click', function(event) {
		event.preventDefault();
		var pid = $(event.target).attr('pid');
		appendPlayer(pid);
		});
		
	$('.remove-player').on('click', function(event) {
		event.preventDefault();
		var pid = $(this).attr('pid');
		removePlayer(pid);
		});
		
	$('[data-toggle="tooltip"]').tooltip();
	
	// Renvoie une fonction de callback qui agrandit le glyphicon correspondant au selector .new-progress{sel}
	function getScaleCallback(sel,scale) {
		return function(event) {
			$('.new-progress'+sel).css('transform', 'scale('+scale+')');
		};
	}
	
	$('.month-legend').hover(getScaleCallback('',1.5),getScaleCallback('',1.0));
	$('.week-legend').hover(getScaleCallback('-week',1.5),getScaleCallback('-week',1.0));
	$('.day-legend').hover(getScaleCallback('-day',1.5),getScaleCallback('-day',1.0));
	
	// Renvoie une fonction de callback pour la couleur donnée
	function getMasqueCallback(color) {
		return function(event) {
			$("tr:not(:has(.table-header)):has(.touched."+color+" , .table-header) *").toggleClass("montre");
			$("tr:not(:has(.touched."+color+" , .table-header)) *").toggleClass("masque");
		};
	}
	
	var players = [ 'red', 'green', 'orange', 'purple', 'cyan', 'white', 'black' ];
	players.forEach(function(item,index) { $('.legend-'+item).hover(getMasqueCallback(item)); });
//	$('.legend-purple').hover(getMasqueCallback('purple'));
	
</script>