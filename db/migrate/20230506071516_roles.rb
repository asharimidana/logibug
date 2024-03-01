class Roles < ActiveRecord::Migration[7.0]
  def change
    create_table :roles do |t|
      t.string :name
      t.references :resource, :polymorphic => true
    end

  add_index(:roles, [ :name, :resource_type, :resource_id ])
  end
end
