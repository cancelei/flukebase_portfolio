class CreateSmtpSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :smtp_settings do |t|
      t.string :address
      t.integer :port
      t.string :domain
      t.string :user_name
      t.string :encrypted_password
      t.boolean :tls_enabled

      t.timestamps
    end
  end
end
