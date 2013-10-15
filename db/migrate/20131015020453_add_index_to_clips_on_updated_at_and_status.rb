class AddIndexToClipsOnUpdatedAtAndStatus < ActiveRecord::Migration
  def change
    add_index :clips, [:status, :updated_at, :word_id]
  end
end
