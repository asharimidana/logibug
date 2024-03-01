class CreateResults < ActiveRecord::Migration[7.0]
  def change
    create_table :results do |t|
      t.bigint :test_case_id
      t.string :actual
      t.integer:status
      t.integer:priority
      t.integer:severity
      t.string :img_url
      t.string :note

      t.timestamps
    end
  end
end
