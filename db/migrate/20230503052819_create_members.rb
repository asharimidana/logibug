class CreateMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :members do |t|
      t.integer :user_id
      t.integer :role_id
      t.integer :project_id
      t.boolean :invite_confirmed, :default => false 

      t.timestamps
    end
  end
end
