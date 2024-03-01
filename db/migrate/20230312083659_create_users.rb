class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      
      t.string :name
      t.string :email
      t.boolean :email_confirmed, :default => false 
      t.string :password_digest
      t.string :confirm_token
      t.string :refres_token

      t.timestamps
    end
  end
end
