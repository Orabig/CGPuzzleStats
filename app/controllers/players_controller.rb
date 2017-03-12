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
  
  # GET /players/refresh
  def refresh
	@cgids = refresh_player_params{:cgids}.split(',')
	@players = @cgids.map { |id| Player.find_by cgid: id }
	@changedPlayers = Array.new
	@refresh_count = 0;
	@refresh_pending = 0;
	for player in @players			
		@refresh_pending += 1
		# Verification de l'état du joueur
		if player.needsRefresh
			player.refresh_pending = true	
			player.save
			@refresh_count += 1
			ResultRefreshJob.perform_later(player)
		end
		@changedPlayers.push player
	end
	@players = @changedPlayers
	render :index
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
end
