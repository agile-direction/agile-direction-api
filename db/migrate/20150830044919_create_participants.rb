class CreateParticipants < ActiveRecord::Migration
  def change
    create_table(:participants, { id: :uuid }) do |t|
      t.uuid(:joinable_id, { null: false })
      t.string(:joinable_type, { null: false })
      t.uuid(:user_id, { null: false })
    end

    add_foreign_key(:participants, :users)
  end
end
