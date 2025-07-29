class CreatePersonalInfos < ActiveRecord::Migration[8.0]
  def change
    create_table :personal_infos do |t|
      t.string :name
      t.string :title
      t.string :email
      t.string :phone
      t.string :location
      t.string :website
      t.string :linkedin
      t.string :twitter
      t.string :github
      t.text :summary

      t.timestamps
    end
  end
end
