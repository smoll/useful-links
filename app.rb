require "byebug"
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

get "/:id" do
  @link = Link.get params[:id]
  @title = "Edit link ##{params[:id]}"
  erb :edit
end

put "/:id" do
  logger.info "Params received: #{params}"
  link_to_edit = Link.get params[:id]
  logger.info "Link object: #{link_to_edit}"
  logger.info "Current link_to_edit archival status: #{link_to_edit.archived}"
  link_to_edit.url = params[:url]
  link_to_edit.archived = params[:archived] ? 1 : 0
  link_to_edit.updated_at = Time.now
  link_to_edit.save
  logger.info "Final link_to_edit archival status: #{link_to_edit.archived}"
  redirect "/links"
end

get "/:id/archived" do
  link = Link.get params[:id]
  logger.info "Current link archival status: #{link.archived}"
  link.archived = link.archived ? 0 : 1 # flip it
  link.created_at = Time.now
  link.updated_at = Time.now
  link.save
  logger.info "Final link archival status: #{link.archived}"
  redirect "/"
end

get "/:id/delete" do
  link = Link.get params[:id]
  link.destroy
  redirect "/"
end
