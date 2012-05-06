# -*- coding: utf-8 -*-
module WordsHelper
  def status_button(duration, status)
    link_to duration, clip_path(@word.clip, clip: {status: status}), class: 'btn', id: "status#{status}", method: :put, remote: true, data: {type: :json}
  end

  def link_to_google(str, query)
    link_to str, "https://www.google.com/search?hl=en&q=#{query}", target: '_blank'
  end

  def preprocess(word)
    entry = word.entry
    body = word.definition
    body = split_example_sentence(body)
    definitions = ""; items = ""; underlined = ""

    body.each_line do |line|
      line.gsub!(entry, "<strong class='highlight'>" + entry + "</strong>")
      line = remove_yomigana(line)

      case line
      when /^(.+{([^}]+)} : .+)$/
        category, content = $2, $1
        if category =~ proper_nouns
          items << "<p>#{content}</p>\n"
        else
          definitions << "<p class='word-definition'>#{content}</p>\n"
        end
      when /^(■.*)$/
        items << "<p>#{$1}</p>\n"
      when /^@(■.*)$/
        underlined << "<p class='underscore'>#{$1}</p>\n"
      end
    end
    definitions + underlined + items
  end

private

  def remove_yomigana(str)
    # ■akin {形} : 血族｛けつぞく｝の、同族｛どうぞく｝の、同種｛どうしゅ｝の
    # → ■akin {形} : 血族の、同族の、同種の
    str.gsub(/｛[^｝]+｝/, '')
  end

  def split_example_sentence(str)
    str.gsub(/■・(.*)$/, "\n■\\1")
  end

  def proper_nouns
    @proper_nouns ||= Regexp.new('組織|商標|著作|映画|小説|雑誌名|新聞名|地名|人名|曲名|バンド名|チーム名|アルバム名')
  end
end
