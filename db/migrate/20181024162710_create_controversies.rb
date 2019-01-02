class CreateControversies < ActiveRecord::Migration[5.2]
  def change
    create_table :controversies, id: false, primary_key: :protocol do |t|
      t.string :protocol, primary_key: true
      t.string :title
      t.string :description
      t.datetime :closed_at
      t.integer :status
      t.integer :CO_SEI
      t.integer :CO_CONTRATO
      t.integer :CO_CIDADE
      t.integer :CO_CNES
      t.integer :company_user_id
      t.integer :unity_user_id
      t.integer :city_user_id
      t.integer :creator
      t.integer :category
      t.integer :complexity
      t.integer :support_1_id
      t.integer :support_2_id

      t.timestamps
    end

    add_foreign_key :controversies, :TB_EMPRESA, column: :CO_SEI, primary_key: :CO_SEI
    add_foreign_key :controversies, :TB_CONTRATO, column: :CO_CONTRATO, primary_key: :CO_CODIGO
    add_foreign_key :controversies, :TB_CIDADE, column: :CO_CIDADE, primary_key: :CO_CODIGO
    add_foreign_key :controversies, :TB_UBS, column: :CO_CNES, primary_key: :CO_CNES
    add_foreign_key :controversies, :users, column: :company_user_id
    add_foreign_key :controversies, :users, column: :unity_user_id
    add_foreign_key :controversies, :users, column: :city_user_id
    add_foreign_key :controversies, :users, column: :support_1_id
    add_foreign_key :controversies, :users, column: :support_2_id
  end
end
