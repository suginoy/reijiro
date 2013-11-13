require 'open-uri'
require 'nokogiri'

class Word < ActiveRecord::Base
  has_one :clip, dependent: :destroy
  has_many :checks, dependent: :destroy
  # TODO: Levelとの間に関連を持たせる
  validates :entry, presence: true
  validates :definition, presence: true
  validates :level, presence: true, inclusion: { in: (0..12).to_a } # Levelは最終的に無くなるので共通化しない

  scope :clipped, -> { joins(:clip) }

  before_validation :set_level

  paginates_per 200

  def set_level
    l = Level.find_by(entry: self.entry)
    self.level = l.nil? ? 0 : l.level # TODO: Levelのモデル名を変更する
  end

  class << self
    def lookup(query)
      normalized_query = normalize_query(query)
      items = Item.where(entry: normalized_query).to_a
      items += Invert.where(token: normalized_query).map(&:item) # TODO: Itemから引いてくる
      items.uniq.map(&:body).join("\n") # TODO: 先にpluckかselectで絞り込む/uniqにブロック使う
    end

    def search(query)
      entry = normalize_query(query)
      definition = lookup(entry)
      thesaurus = lookup_thesaurus(entry)
      if definition.empty?
        nil # TODO: nil返さない
      else
        @word = Word.new(entry: entry, thesaurus: thesaurus, definition: definition)
        @word.build_clip(status: 0)
        @word.save!
      end
    end

    # search the query on the thesaurus.com and paste part of the
    # result.
    def lookup_thesaurus(query)
      normalized_query = normalize_query(query).gsub(/ /, '+')  # TODO: gsubもnormarilze_queryメソッド内部に入らないか
      begin
        html = Nokogiri::HTML(open("http://thesaurus.com/browse/#{normalized_query}").read)
        html.css('.sep_top')[0].to_s.gsub(/<\/a>/, '').gsub(/<a[^>]+>/, '')
      rescue
        "none"
      end
    end

    def imported_entries
      Word.pluck(:entry)
    end

    private

    def normalize_query(query)
      query.downcase.gsub(/ +$/, '')
    end
  end
end
