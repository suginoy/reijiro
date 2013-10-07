class LevelsController < ApplicationController
  def index
    # TODO: @to_importって使われていなくないか？？
    @to_import = Array.new(12 + 1)
    (1..12).each do |level|
      @to_import[level] = Level.yet_to_import(level, 5)
    end
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
