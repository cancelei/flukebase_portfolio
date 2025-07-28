class CreateSiteSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :site_settings do |t|
      t.string :key
      t.string :value
      t.string :value_type

      t.timestamps
    end
    add_index :site_settings, :key, unique: true
  end
end
