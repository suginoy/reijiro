class ClipsController < ApplicationController
  def index
    # TODO: リテラル使わずにハッシュで書く
    @words = Word.joins(:clip).where.not(clips: { status: 8 }).order("clips.updated_at DESC").page params[:page]
    @list_title = "Clipped words"

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @clips }
    end
  end

  def all
    @words = Word.joins(:clip).order("clips.updated_at DESC")
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
    @clip = Clip.find(params[:id])
    # TODO: touchからupdate_attributesまで1メソッドにする
    # TODO: CheckをWordに紐づけずClipに紐づくようにする(勘定パタン
    @clip.touch # touch the record, even if there's no change # TODO: 削除可能か調べる

    @clip.word.checks.build(oldstat: @clip.status, newstat: params[:clip]['status'])

    respond_to do |format|
      if @clip.update_attributes(params[:clip])
        format.html { redirect_to @clip, notice: 'Clip was successfully updated.' }
        format.json { render json: @clip }
      else
        format.html { render action: "edit" }
        format.json { render json: @clip.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @clip = Clip.find(params[:id])
    @clip.destroy

    respond_to do |format|
      format.html { redirect_to clips_url }
      format.json { head :no_content }
    end
  end

  def stats
    @check_months = Check.check_months
    @stats = Clip.stats

    respond_to do |format|
      format.html
      format.json { render json: @stats }
    end
  end
end
