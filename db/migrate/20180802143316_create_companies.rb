class CreateCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :companies, id: false do |t|
      t.integer :sei

      t.timestamps
    end
    add_index :companies, :sei, unique: true
  end
end
