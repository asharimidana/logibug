class CreateProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :profiles do |t|
      t.bigint :user_id
      t.string :img_url

      t.timestamps
    end
  end
end
