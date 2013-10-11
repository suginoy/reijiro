class AddIndexCreatedOnToChecks < ActiveRecord::Migration
  def change
    add_index :checks, :created_on
    remove_index :checks, :created_at
  end
end
