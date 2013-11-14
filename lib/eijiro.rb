# -*- coding: utf-8 -*-
require 'kconv'
require 'sqlite3'
require 'yaml'
require 'ruby-progressbar'
require 'eijiro/sqlprocessor'

class EijiroDictionary
  def initialize(path)
    @eijiro_files = find_dictionaries(path)
    @dbfile = File.join(Rails.root, 'db', Rails.env + '.sqlite3')
    @level_table = {}
    @sql = SqlProcessor.new
    @id = 0
  end

  def convert_to_sql
    @eijiro_files.each do |dic|
      File.open(dic) do |f|
        number_of_lines = %x{ wc -l #{dic}}.split.first.to_i
        puts "Convert Eijiro file to sql: #{dic}\n (#{number_of_lines} entries)"
        pbar = ProgressBar.create(title: "Converting", total: number_of_lines)

        f.each_line do |l|
          line = Kconv.kconv(l, Kconv::UTF8, Kconv::SJIS) # TODO: Kconv使わない
          line.gsub!(/◆.+$/, '')
          if line =~ /■(.*?)(?:  ?\{.*?\})? : (【レベル】([0-9]+))?/
            @id += 1
            entry = $1.downcase
            level = $3 ? $3.to_i : 0
            if level != 0
              @level_table[level] ||= []
              @level_table[level] << entry
            end
            body = line.chomp
            @sql.generate(@id, entry, body)
            pbar.increment
          end
        end
        pbar.finish
      end
    end
  end

  def write_to_database
    puts "\nWriting to the database tables."
    puts "This process may take several minutes."
    @sql.finish
    puts "Done."
  end

  def write_level
    puts "Writing to level table..."
    db = SQLite3::Database.new(@dbfile)
    @level_table.each do |level, entries|
      entries.each do |entry|
        db.execute("INSERT INTO levels (entry, level) VALUES (#{sqlstr(entry)}, #{level});")
      end
    end
    db.close
  end

  def import_acl_12000
    puts "Import ALC12000 words..."
    db = SQLite3::Database.new(@dbfile)
    (1..12).each do |level|
      pbar = ProgressBar.new("Level #{level}", Level.where(level: level).count)
      Level.where(level: level).map(&:entry).each do |entry|
        word.downcase!
        pbar.increment
        eijiro = db.execute("SELECT items.body FROM items WHERE entry = #{sqlstr(entry)}")
        reijiro = db.execute("SELECT items.body FROM items INNER JOIN inverts ON items.id = inverts.item_id WHERE inverts.token = #{sqlstr(entry)} AND items.entry != #{sqlstr(entry)}")
        definition = (eijiro + reijiro).join("\n")
        db.execute("INSERT INTO words (entry, level, definition) VALUES (#{sqlstr(entry)}, #{level}, #{sqlstr(definition)});")
      end
      pbar.finish
    end
    db.close
  end

private

  def find_dictionaries(path)
    eijiro_files = []
    Dir.foreach(path) do |file|
      case file
        when /^EIJI-.*\.TXT/i
        eijiro_files << File.join(path, file)
      when /^REIJI.*\.TXT/i
        eijiro_files << File.join(path, file)
      end
    end
    raise "No dictionary files found" if eijiro_files.empty?
    eijiro_files
  end

  def sqlstr(str)
    "'#{str.gsub(/'/,"''")}'"
  end
end
