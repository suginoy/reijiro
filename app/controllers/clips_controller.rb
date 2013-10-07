class ClipsController < ApplicationController
  before_action :set_clip, only: [:update, :destroy]

  def index
    @words = Word.clipped.merge(Clip.display.undone).page params[:page] # Clip.undone.displayだとバグになる
    @list_title = "Clipped words"

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @clips }
    end
  end

  def all
    @words = Word.clipped.merge(Clip.display)
    @list_title = "All clips"
  end

  def next
    clip = Clip.next_clip
    if clip
      @word = clip.word
      render template: 'words/show'
    else
      redirect_to levels_path, notice: "No more items to review. Want to clip a little more words?"
    end
  end

  def nextup
    @words = Clip.next_list.page params[:page]
    @list_title = "Words to review"
    render 'index'
  end

  def update
    respond_to do |format|
      if @clip.update_with_checking_word(clip_params)
        format.html { redirect_to @clip, notice: 'Clip was successfully updated.' }
        format.json { render json: @clip }
      else
        format.html { render action: "edit" }
        format.json { render json: @clip.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @clip.destroy

    respond_to do |format|
      format.html { redirect_to clips_url }
      format.json { head :no_content }
    end
  end

  def stats
    @checks_per_date = Check.checks_per_date
    @stats = Clip.stats

    respond_to do |format|
      format.html
      format.json { render json: @stats }
    end
  end

  private

    def set_clip
      @clip = Clip.find(params[:id])
    end

    def clip_params
      params.permit(:id, :word_id, :status)
    end

end
