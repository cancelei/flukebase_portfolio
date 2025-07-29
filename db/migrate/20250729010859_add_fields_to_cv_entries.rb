class AddFieldsToCvEntries < ActiveRecord::Migration[8.0]
  def change
    add_column :cv_entries, :entry_type, :string
    add_column :cv_entries, :company, :string
    add_column :cv_entries, :location, :string
    add_column :cv_entries, :start_date, :date
    add_column :cv_entries, :end_date, :date
    add_column :cv_entries, :current, :boolean
  end
end
