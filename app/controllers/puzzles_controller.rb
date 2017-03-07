class PuzzlesController < ApplicationController
  before_action :set_puzzle, only: [:show, :edit, :update, :destroy, :import, :results]

  # GET /puzzles
  # GET /puzzles.json
  def index
    @puzzles = Puzzle.all.without_community
	if params[:level]
	  @puzzles = @puzzles.by_level(params[:level])
	end
	if params[:pid]
		@pids = params[:pid].split(',')
		@results = Array.new
		for pid in @pids
			player = Player.find_by(cgid: pid)
			@results.push( Result.where(player: player) )
		end
		@results = @results.flatten.group_by {|r| "#{r.player_id}:#{r.puzzle_id}:#{r.language_id}"}
	end
  end

  # GET /puzzles/seed
  def seed
    text = File.read(Rails.root.join('app','models','seed','findGamePuzzleProgress.json'))
	json = JSON.parse(text)
	json["success"].each do |p|
	  new_puzzle = Puzzle.new
	  new_puzzle.cgid=p["id"]
	  new_puzzle.title=p["title"]
	  new_puzzle.description=p["description"]
	  new_puzzle.detailsPageUrl=p["detailsPageUrl"]
	  new_puzzle.level=p["level"]
	  new_puzzle.prettyId=p["prettyId"]
	  new_puzzle.solvedCount=p["solvedCount"]
	  new_puzzle.puzzleType=p["type"]
	  new_puzzle.leaderboardId=p["puzzleLeaderboardId"]
	  new_puzzle.achievementCount=p["achievementCount"]
	  new_puzzle.save
	end
	redirect_to puzzles_url
  end

  # GET /puzzles/1
  # GET /puzzles/1.json
  def show
  end

  # GET /puzzles/new
  def new
    @puzzle = Puzzle.new
  end

  # GET /puzzles/1/edit
  def edit
  end
  
  # GET /puzzles/1/results
  def results
	api = CodingameApi.new
	@results = Player.all.map { |p| [p.pseudo , api.puzzle_player_langages(@puzzle,p)] }.to_h
  end

  # POST /puzzles/1/import
  def import
	api = CodingameApi.new
	response = api.puzzle_leaderboard @puzzle
	if response.message=="OK"
		result = JSON.parse( response.body )
		@test = result['success']['users']
	else
		@test = [ "CG API Error" ]
	end
  end

  # POST /puzzles
  # POST /puzzles.json
  def create
    @puzzle = Puzzle.new(puzzle_params)

    respond_to do |format|
      if @puzzle.save
        format.html { redirect_to @puzzle, notice: 'Puzzle was successfully created.' }
        format.json { render :show, status: :created, location: @puzzle }
      else
        format.html { render :new }
        format.json { render json: @puzzle.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /puzzles/1
  # PATCH/PUT /puzzles/1.json
  def update
    respond_to do |format|
      if @puzzle.update(puzzle_params)
        format.html { redirect_to @puzzle, notice: 'Puzzle was successfully updated.' }
        format.json { render :show, status: :ok, location: @puzzle }
      else
        format.html { render :edit }
        format.json { render json: @puzzle.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /puzzles/1
  # DELETE /puzzles/1.json
  def destroy
    @puzzle.destroy
    respond_to do |format|
      format.html { redirect_to puzzles_url, notice: 'Puzzle was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_puzzle
      @puzzle = Puzzle.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def puzzle_params
      params.require(:puzzle).permit(:cgid, :title, :description, :detailsPageUrl, :level, :prettyId, :solvedCount, :type, :achievementCount)
    end
end
