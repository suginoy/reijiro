class AddIndexItemIdToInverts < ActiveRecord::Migration
  def change
    add_index :inverts, :item_id
  end
end
