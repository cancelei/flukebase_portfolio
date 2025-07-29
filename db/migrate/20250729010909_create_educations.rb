class CreateEducations < ActiveRecord::Migration[8.0]
  def change
    create_table :educations do |t|
      t.string :institution
      t.string :degree
      t.string :field_of_study
      t.date :start_date
      t.date :end_date
      t.boolean :current
      t.string :gpa
      t.text :achievements
      t.integer :position

      t.timestamps
    end
  end
end
