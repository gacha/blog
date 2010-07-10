require 'sinatra'
require 'dm-core'
require 'dm-validations'
require 'appengine-apis/users'
require 'appengine-apis/memcache'
DataMapper.setup(:default, "appengine://auto")

# load models
Dir.glob("models/*.rb").each {|f| require(f) }

# load controllers
Dir.glob("controllers/*.rb").each {|f| require(f) }

# load helpers
Dir.glob("helpers/*.rb").each {|f| require(f) }

# load libs
Dir.glob("lib/*.rb").each {|f| require(f) }

require 'erubis'

set :erubis, {:layout => :default}

# controllers
include PageController
include TagController
include BlogController

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