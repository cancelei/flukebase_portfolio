class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.string :title, null: false
      t.text :description
      t.string :slug
      t.string :github_url
      t.string :demo_url
      t.boolean :published, default: false
      t.string :source, default: 'manual'

      t.timestamps
    end
    add_index :projects, :slug, unique: true
  end
end
