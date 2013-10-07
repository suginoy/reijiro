class WordsController < ApplicationController
  before_action :set_word, only: [:show, :edit, :update, :destroy]

  def index
    @words = Word.limit(50)  # TODO: ->定数化->マスタ化
    respond_to do |format|
      format.html
      format.json { render json: @words }
    end
  end

  def show
  end

  def create
    @word = Word.new(params[:word])
    @word.build_clip(status: 0) # 元々の仕様levelもコピーされるべきだった？

    respond_to do |format|
      if @word.save
        format.html { redirect_to @word, notice: 'Clip was successfully created.' }
        format.json { render json: @word, status: :created, location: @word }
      else
        format.html { render action: "search" }
        format.json { render json: @word.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @word.update_attributes(params[:word])
        format.html { redirect_to @word, notice: 'Word was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @word.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @word.destroy

    respond_to do |format|
      format.html { redirect_to root_url, notice: 'Deleted a word.' }
      format.json { head :no_content }
    end
  end

  def search
    @query = params[:query].downcase.chomp # TODO: Strong Prameters使う/@queryはインスタンス変数の必要があるか確認
    if @word = Word.find_by(entry: @query)
      flash.now[:success] = "Already clipped!"
      render 'show'
    elsif @word = Word.search(@query)
      flash.now[:success] = "Found and clipped!"
      render 'show'
    end
    @word = Word.new(entry: @query)
  end

  def import
    @words = []
    new_words = params.select { |k, v| v == "1" }.keys # TODO: ナニコレ？
    new_words.each do |w|
      @words << Word.search(w)
    end
    flash[:notice] = "Imported #{'word'.pluralize(@words.count)}."
    render "words/import"
  end

  def async_import
    @query = params[:word].downcase.chomp
    if Word.where(entry: @query).empty?
      EM.defer do
        @word = Word.search(@query)
      end
      render nothing: true
    end
  end

  private

    def set_word
      @word = Word.find(params[:id])
    end
end
