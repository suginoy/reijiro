class RenameLevelsWordToEntry < ActiveRecord::Migration
  def change
    rename_column :levels, :word, :entry
  end
end
