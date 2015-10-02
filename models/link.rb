class Link
  include DataMapper::Resource

  property :id,          Serial
  property :url,         Text,    required: true
  property :description, Text
  property :archived,    Boolean, required: true, default: false
  property :created_at,  DateTime
  property :updated_at,  DateTime
end
