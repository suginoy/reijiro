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
    @word = Word.new(word_params)
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
      if @word.update_attributes(word_params)
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
    @query = query_params[:query].downcase.chomp
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
    @words = new_words_params.inject([]) do |total, word|
      total << Word.search(word)
    end
    flash[:notice] = "Imported #{'word'.pluralize(@words.count)}."
    render "words/import"
  end

  def async_import
    @query = query_params[:word].downcase.chomp # TODO: パラメータ名変える
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

    def word_params
      params.require(:word).permit(:entry, :definition)
    end

    def query_params
      params.permit(:query, :word)
    end

    def new_words_params
      params.permit(params.select { |k, v| v == "1" }.keys.to_sym) # TODO: ナニコレ？
    end
end
