class AddIndexCreateAtToChecks < ActiveRecord::Migration
  def change
    add_index :checks, :created_at
  end
end
