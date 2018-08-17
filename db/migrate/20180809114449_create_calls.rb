class CreateCalls < ActiveRecord::Migration[5.2]
  def change
    create_table :calls do |t|
      t.string :title
      t.text :description
      t.datetime :finished_at
      t.integer :status
      t.string :version
      t.string :access_profile
      t.string :feature_detail
      t.string :answer_summary
      t.string :severity
      t.string :protocol
      t.references :city, foreign_key: true
      t.references :category, foreign_key: true
      t.references :state, foreign_key: true
      t.integer :sei

      t.timestamps
    end
    add_foreign_key :calls, :companies, column: :sei, primary_key: :sei
  end
end
