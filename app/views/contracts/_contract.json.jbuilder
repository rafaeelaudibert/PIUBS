json.extract! contract, :id, :filename, :content_type, :file_contents, :created_at, :updated_at
json.url contract_url(contract, format: :json)
