require "data_mapper"
require "json"
require "sinatra"

# Load models
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/models")
Dir.glob("#{File.dirname(__FILE__)}/models/*.rb") { |model| require File.basename(model, ".*") }

# Create table, migrations, etc.
DataMapper.setup(:default, (ENV["DATABASE_URL"] || "sqlite3:///#{File.expand_path(File.dirname(__FILE__))}/#{Sinatra::Base.environment}.db"))
DataMapper.finalize
DataMapper.auto_upgrade!

get "/" do
  @links = Link.all(order: :id.desc)
  @title = "All Links"
  erb :home
end

post "/" do
  link = Link.new
  link.url = params[:url]
  link.description = params[:description]
  link.created_at = Time.now
  link.updated_at = Time.now
  link.save
  redirect "/"
end

get "/links" do
  content_type "application/json"
  Link.all(order: :id.desc).to_json
end
