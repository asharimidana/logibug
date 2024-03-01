class AddUserNameToResults < ActiveRecord::Migration[7.0]
  def change
    add_column :results, :user_name, :string
  end
end
