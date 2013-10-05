class AddIndexWordIdToClips < ActiveRecord::Migration
  def change
    add_index :clips, :word_id, unique: true
  end
end
