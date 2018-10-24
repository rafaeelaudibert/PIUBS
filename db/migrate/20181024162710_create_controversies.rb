class CreateControversies < ActiveRecord::Migration[5.2]
  def change
    create_table :controversies, id: false, primary_key: :protocol do |t|
      t.string :protocol, primary_key: true
      t.string :title
      t.string :description
      t.datetime :closed_at
      t.integer :status
      t.integer :sei
      t.integer :contract_id
      t.integer :city_id
      t.integer :cnes
      t.integer :company_user_id
      t.integer :unity_user_id
      t.integer :creator
      t.integer :category
      t.integer :complexity
      t.integer :support_1_id
      t.integer :support_2_id

      t.timestamps
    end

    add_foreign_key :controversies, :companies, column: :sei, primary_key: :sei
    add_foreign_key :controversies, :contracts
    add_foreign_key :controversies, :cities
    add_foreign_key :controversies, :unities, column: :cnes, primary_key: :cnes
    add_foreign_key :controversies, :users, column: :company_user_id
    add_foreign_key :controversies, :users, column: :unity_user_id
    add_foreign_key :controversies, :users, column: :support_1_id
    add_foreign_key :controversies, :users, column: :support_2_id
  end
end
