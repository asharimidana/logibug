class CreateAutomatics < ActiveRecord::Migration[7.0]
  def change
    create_table :automatics do |t|
      t.string :json_url

      t.timestamps
    end
  end
end
