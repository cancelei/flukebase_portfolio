class CreateSkills < ActiveRecord::Migration[8.0]
  def change
    create_table :skills do |t|
      t.string :name
      t.string :category
      t.integer :proficiency_level
      t.integer :position

      t.timestamps
    end
  end
end
