class AddColomnVersionIdAutomaticTest < ActiveRecord::Migration[7.0]
  def change
    add_column :automatics, :version_id, :integer
  end
end
