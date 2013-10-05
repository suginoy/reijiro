class Level < ActiveRecord::Base
  # TODO: add validation
  scope :known,   -> { where(known: true) }
  scope :unknown, -> { where(known: false) }

  class << self
    def yet_to_import(level, max = 10)
      levels =
        Level.unknown
        .where(level: level)
        .where.not(entry: Word.imported_entries)
        .limit(max).pluck(:word)
      if words.empty?
        nil # TODO: nilを返す必要があるか確認
      else
        levels
      end
    end
  end
end
