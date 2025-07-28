class CreateBlogPosts < ActiveRecord::Migration[8.0]
  def change
    create_table :blog_posts do |t|
      t.string :title, null: false
      t.string :slug
      t.boolean :published, default: false
      t.datetime :published_at

      t.timestamps
    end
    add_index :blog_posts, :slug, unique: true
  end
end
