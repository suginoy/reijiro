class LevelsController < ApplicationController
  def index
  end

  def show
    @levels =
      Level.unknown
      .where(level: params[:level])
      .where.not(entry: Word.imported_entries) # TODO: NOT使わない/modelに同じコードがあるので共通化
  end

  def known
    level = Level.find(params[:id])
    level.update_column(:known, true) # TODO: update_columnのインターフェース変更確認
    render text: params[:id]
  end
end
