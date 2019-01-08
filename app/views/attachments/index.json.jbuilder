json.array! @attachments do |attachment|
  json.extract! attachment, :id, :filename, :content_type
end
