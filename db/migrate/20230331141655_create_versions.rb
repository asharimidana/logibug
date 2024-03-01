class CreateVersions < ActiveRecord::Migration[7.0]
  def change
    create_table :versions do |t|
      t.bigint :project_id
      t.string :name
      t.boolean :status, default: false

      t.timestamps
    end
  end
end
