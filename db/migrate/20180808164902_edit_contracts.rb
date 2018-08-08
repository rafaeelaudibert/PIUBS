class EditContracts < ActiveRecord::Migration[5.2]
  def self.up
    remove_column :contracts, :files
    add_column :contracts, :filename, :string
    add_column :contracts, :content_type, :string
    add_column :contracts, :file_contents, :binary
  end

  def self.down; end
end
