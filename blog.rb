require 'sinatra'
require 'dm-core'
require 'dm-validations'
require 'appengine-apis/users'
DataMapper.setup(:default, "appengine://auto")
require 'models/article.rb'
require 'controllers/blog.rb'
require 'erubis'
set :erubis, {:layout => :default}

# controllers
include Blog

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/' do
  erubis :index
end