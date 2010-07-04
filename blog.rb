require 'sinatra'
require 'dm-core'
require 'dm-validations'
require 'appengine-apis/users'
require 'appengine-apis/memcache'
DataMapper.setup(:default, "appengine://auto")
require 'models/article.rb'
require 'controllers/blog.rb'
require 'helpers/article_helper.rb'
require 'erubis'

set :erubis, {:layout => :default}

# load libs
Dir.glob("lib/*.rb").each {|f| require(f) }

# controllers
include Blog

helpers do
  include ArticleHelper
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/' do
  aggregator = Aggregator.new
  @flickr = aggregator.load_flickr_images
  @tweets = aggregator.load_tweets
  @delicious = aggregator.load_bookmarks
  erubis :index
end

not_found do
  'Nevar atrast!'
end