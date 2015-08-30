class AddPublicityToMissions < ActiveRecord::Migration
  def change
    add_column(:missions, :public, :boolean, { default: true })
  end
end
