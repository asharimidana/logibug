class CreateApiTestings < ActiveRecord::Migration[7.0]
  def change
    create_table :api_testings do |t|
      t.json :payload

      t.timestamps
    end
  end
end
