require 'open-uri'
require 'nokogiri'

class Word < ActiveRecord::Base
  has_one :clip, dependent: :destroy
  has_many :checks, dependent: :destroy
  # TODO: Levelとの間に関連を持たせる
  validates :entry, :definition, :level, presence: true

  # TODO: NOT IN/JOIN使わない
  scope :unclipped, -> { where('id NOT IN (SELECT word_id FROM words INNER JOIN clips ON words.id = clips.word_id)') }

  before_save :set_level # TODO: before_validationにする
  paginates_per 200

  def set_level
    l = Level.where(word: entry) # TODO: findを使う
    self.level = l.empty? ? 0 : l.first.level  # TODO: Levelのモデル名を変更するか
  end

  class << self
    def lookup(query)
      query = normalize_query(query) # TODO: 引数を上書きしない
      items = Item.where(entry: query).to_a
      items += Invert.where(token: query).map(&:item) # TODO: Itemから引いてくる
      items.uniq.map(&:body).join("\n") # TODO: 先にpluckかselectで絞り込む
    end

    def search(query)
      query = normalize_query(query) # TODO: 引数を上書きしない
      definition = lookup(query)
      thesaurus = lookup_thesaurus(query)
      unless definition.empty? # TODO: if使う
        word = Word.create(entry: query, # new使う
                           thesaurus: thesaurus,
                           definition: definition)
        word.create_clip(status: 0) # buildとsave!使う
        word
      else
        nil # TODO: nil返さない
      end
    end

    # search the query on the thesaurus.com and paste part of the
    # result.
    def lookup_thesaurus(query)
      query = normalize_query(query).gsub(/ /, '+') # TODO: 引数を上書きしない
      begin
        html = Nokogiri::HTML(open("http://thesaurus.com/browse/#{query}").read)
        html.css('.sep_top')[0].to_s.gsub(/<\/a>/, '').gsub(/<a[^>]+>/, '')
      rescue
        "none"
      end
    end

    def imported_list
      list = Word.pluck(:entry)
      list.empty? ? '' : list
    end

    private

    def normalize_query(query)
      query.downcase.gsub(/ +$/, '')
    end
  end
end
