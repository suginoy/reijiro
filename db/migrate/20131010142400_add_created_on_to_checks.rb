class AddCreatedOnToChecks < ActiveRecord::Migration
  def self.up
    add_column :checks, :created_on, :date

    Check.where(created_on: nil).each do |check|
      check.update_attribute(:created_on, self.created_at.to_date)
    end
  end

  def self.down
    remove_column :checks, :created_on
  end
end
