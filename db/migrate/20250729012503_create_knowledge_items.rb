class CreateKnowledgeItems < ActiveRecord::Migration[8.0]
  def change
    create_table :knowledge_items do |t|
      t.string :content_type
      t.integer :content_id
      t.text :title
      t.text :content
      t.text :embedding

      t.timestamps
    end
  end
end
