require 'ruby-progressbar'

class EijiroDictionary
  class SqlProcessor
    # TODO: マスタ化すると他でも使える
    COMMON_TOKENS = %w(i ll  mr ok a about after all also an and any are as at back be because been before but by can can t come could day did didn do don down even first for from get give go going good got great had has have he he her here hey him his how if in into is it its just know like little look made make man may me mean men more most much must my new no not now of oh okay on one only or other our out over person really right said say see she should so some something such take tell than that that the their them then there these they think this time to two up upon us use very want was way we well were what when which who why will with work would yeah year yes you you re your)

    class SqlFile
      def initialize
        @num = "001"
        @path = File.join(Rails.root, "db")
      end

      def current_file
        File.join(@path, "eijiro#{@num}.sql")
      end

      def open
        File.open(current_file, "w") do |f|
          f.write "BEGIN TRANSACTION;\n" # TODO: 改行付き書くメソッド
        end
      end

      def write(queries)
        File.open(current_file, "a") do |f|
          f.write queries.join("\n")
        end
      end

      def close
        File.open(current_file, "a") do |f|
          f.write "\nEND TRANSACTION;\n"
        end
        @num = @num.succ
      end
    end

    def initialize(database)
      @flush_limit = 10_0000
      @sqlfile = SqlFile.new
      @sqlfile.open
      @queries = []
      @database = database
    end

    def generate(id, entry, body)
      @queries << "INSERT INTO items (entry, body) VALUES (#{sqlstr(entry)}, #{sqlstr(body)});"
      tokenize(entry).each do |token| # TODO: BULK INSERT
        @queries << "INSERT INTO inverts (token, item_id) VALUES (#{sqlstr(token)}, #{id});"
      end
      if id % @flush_limit == 0
        flush
        @sqlfile.close
        @sqlfile.open
      end
    end

    def flush
      @sqlfile.write(@queries)
      @queries = []
    end

    def execute_queries
      flush
      n = %x{ ls -1 #{File.join(Rails.root, "db", "eijiro*.sql")} |wc -l }.chomp.strip.to_i
      pbar = ProgressBar.create(title: "Executing SQL commands...", total: n)
      Dir.glob(File.join(Rails.root, "db", "eijiro*.sql")).each do |sql_file|
        pbar.increment
        system("sqlite3 #{@database} \".read #{sql_file}\"")
        system("rm #{sql_file}")
      end
      pbar.finish
    end

    def tokenize(str)
      str.split(/[ \-\.\'\%\"\/\,]/)
        .map(&:downcase)
        .reject { |s| s.size <= 1 || COMMON_TOKENS.include?(s) }
    end

    def sqlstr(str)
      "'#{str.gsub(/'/,"''")}'"
    end
  end
end
