class CreateProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.integer :type_test, default: 0 
      t.integer :platform, default: 0

      t.timestamps
    end
  end
end
