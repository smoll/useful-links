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

get "/:id" do
  @link = Link.get params[:id]
  @title = "Edit link ##{params[:id]}"
  erb :edit
end

put "/:id" do
  link = Link.get params[:id]
  logger.error "Can't find note #{params[:id]}" unless link

  link.url = params[:url].empty? ? link[:url] : params[:url]
  link.archived = params[:archived] ? 1 : 0
  link.updated_at = Time.now

  if link.save
    logger.info "Successfully updated link."
  else
    logger.error "Error updating link! *** params info: #{params.inspect} *** link info: #{link.inspect}"
  end
  redirect "/"
end

get "/:id/archived" do
  link = Link.get params[:id]
  link.archived = link.archived ? 0 : 1 # flip it
  link.updated_at = Time.now
  link.save
  redirect "/"
end

get "/:id/delete" do
  link = Link.get params[:id]
  link.destroy
  redirect "/"
end
