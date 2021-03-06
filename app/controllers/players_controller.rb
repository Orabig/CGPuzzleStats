class PlayersController < ApplicationController
  before_action :set_player, only: [:show, :edit, :update, :destroy]

  # GET /players
  # GET /players.json
  def index
    @players = Player.all
  end

  # GET /players/1
  # GET /players/1.json
  def show
  end

  # GET /players/new
  def new
    @player = Player.new
  end

  # GET /players/1/edit
  def edit
  end
  
  # GET /search
  def search
    query = params[:query]
	api = CodingameApi.new
	response = api.player_search( query )	
	if response.message=="OK"
		 result = JSON.parse( response.body )
		 @players = result['success']['users']
		 # Traduction des champs
		 @players = @players.map {|p| { cgid: p["codingamer"]["userId"], rank: p["rank"], pseudo: p["pseudo"], level: p["codingamer"]["level"] } }
		 # Pre-chargement des joueurs en base
		 for player in @players
			Player.create_with(rank: player[:rank], level: player[:level]).find_or_create_by(cgid: player[:cgid], pseudo: player[:pseudo])
		 end
	else
		@players = [ "CG API Error" ]
	end
  end

  # POST /players
  # POST /players.json
  def create
    @player = Player.new(player_params)

    respond_to do |format|
      if @player.save
        format.html { redirect_to @player, notice: 'Player was successfully created.' }
        format.json { render :show, status: :created, location: @player }
      else
        format.html { render :new }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /players/1
  # PATCH/PUT /players/1.json
  def update
    respond_to do |format|
      if @player.update(player_params)
        format.html { redirect_to @player, notice: 'Player was successfully updated.' }
        format.json { render :show, status: :ok, location: @player }
      else
        format.html { render :edit }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /players/save
  def save
	@player = Player.new
    respond_to do |format|
      if @player.update(save_player_params)
        format.html { redirect_to @player, notice: 'Player was successfully updated.' }
        format.json { render :show, status: :ok, location: @player }
      else
        format.html { render :edit }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # GET /players/isRefreshPending
  def isRefreshPending
	@cgids = refresh_player_params{:cgids}.split(',')
	@players = @cgids.map { |id| Player.find_by cgid: id }
	@refresh_pending = 0;
	for player in @players
		if player.refresh_pending
			@refresh_pending += 1
		else
			check_refresh_state player
		end
	end
	render :refresh
  end
  
  # GET /players/refresh
  def refresh
	@cgids = refresh_player_params{:cgids}.split(',')
	@players = @cgids.map { |id| Player.find_by cgid: id }
	@refresh_pending = 0;
	for player in @players
		if player.refresh_pending
			@refresh_pending += 1
		else
			# Verification de l'�tat du joueur
			if player.needsRefresh 2 # minutes min between refreshs
				player.refresh
				@refresh_pending += 1
			end
		end
	end
  end
  
  # GET /players/ranking
  def ranking
	@cgids = refresh_player_params{:cgids}.split(',')
	@players = @cgids.map { |id| Player.find_by cgid: id }
	@scores = Hash.new
	@langs = Hash.new
	@achievements = Hash.new
	for player in @players
		score = Hash.new
		for level in [ 'easy', 'medium', 'hard', 'expert' ]
			score[ level.to_sym ] = Puzzle.joins(:results).where(results: {player_id: player.id}, level: level).distinct.count
		end
		score [ :score ] = score [ :easy ] + 20 * (score [ :medium ] + 20 * (score [ :hard ] + 20 * (score [ :expert ]))) 
		@scores[ player.id ] = score
		@langs[ player.id ] = player.results.joins(:language).group("languages.name").order("count_all DESC").count		
	end
	for lang in Language.all
		@achievements[ lang.name ] = Achievement.where(language: lang.id)
	end
  end

  # DELETE /players/1
  # DELETE /players/1.json
  def destroy
    @player.destroy
    respond_to do |format|
      format.html { redirect_to players_url, notice: 'Player was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_player
      @player = Player.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def player_params
      params.require(:player).permit(:cgid, :pseudo, :rank, :level)
    end
    def save_player_params
      params.permit(:cgid, :pseudo, :rank, :level)
    end
    def refresh_player_params
      params.require(:cgids)
    end

	# Checks the state of a player.
	# - if it's reloading for too much time, then cancel this state
	# - if the player is not up to date, refresh it
	def check_refresh_state(player)
		if player.isRefreshTimeout
			player.refresh_pending=false
			player.save
		end
		if player.needsRefresh (60 * 12)
			player.refresh
		end
	end
end
