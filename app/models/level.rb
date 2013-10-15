class Level < ActiveRecord::Base
  scope :known,   -> { where(known: true) }
  scope :unknown, -> { where(known: false) }

  validates :entry, presence: true
  validates :level, presence: true, inclusion: { in: (0..12).to_a }

  after_initialize :set_default_values

  def set_default_values
    self.level ||= 0
    self.known ||= false
  end

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
