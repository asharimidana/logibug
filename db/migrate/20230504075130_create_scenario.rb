class CreateScenario < ActiveRecord::Migration[7.0]
  def change
    create_table :scenarios do |t|
      t.integer :project_id
      t.string :name

      t.timestamps
    end
  end
end
