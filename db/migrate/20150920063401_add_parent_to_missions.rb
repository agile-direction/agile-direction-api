class AddParentToMissions < ActiveRecord::Migration
  def change
    add_column(:missions, :parent_id, :uuid)
  end
end
