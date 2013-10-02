class Level < ActiveRecord::Base
  # TODO: add validation
  scope :known,   -> { where(known: true) }
  scope :unknown, -> { where(known: false) }

  class << self
    def yet_to_import(level, max = 10)
      words =
        Level.unknown
        .where(level: level)
        .where.not(word: Word.imported_list)
        .limit(max).pluck(:word)
      if words.empty?
        nil # TODO: nilを返す必要があるか確認
      else
        words
      end
    end
  end
end
