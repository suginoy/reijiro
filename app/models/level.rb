class Level < ActiveRecord::Base
  # TODO: add validation
  scope :known,   -> { where(known: true) }
  scope :unknown, -> { where(known: false) }

  class << self
    def yet_to_import(level, max = 10)
      entries =
        Level.unknown
        .where(level: level)
        .where.not(entry: Word.imported_entries)
        .limit(max).pluck(:entry)
      if entries.empty?
        nil # TODO: nilを返す必要があるか確認
      else
        entries
      end
    end
  end
end
