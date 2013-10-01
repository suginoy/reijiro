class Level < ActiveRecord::Base
  # TODO: add validation
  scope :known,   -> { where(known: true) }
  scope :unknown, -> { where(known: false) }

  class << self
    def yet_to_import(level, max = 10)
      words =
        Level.unknown
        .where(level: level)
        .where("word NOT IN (?)", Word.imported_list)  # NOT使わない
        .limit(max).pluck(:word)
      unless words.empty?  # if 使う
        words
      else
        nil
      end
    end
  end
end
