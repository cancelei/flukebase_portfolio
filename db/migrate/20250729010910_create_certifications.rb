class CreateCertifications < ActiveRecord::Migration[8.0]
  def change
    create_table :certifications do |t|
      t.string :name
      t.string :issuer
      t.date :issue_date
      t.date :expiry_date
      t.string :credential_id
      t.string :credential_url
      t.integer :position

      t.timestamps
    end
  end
end
