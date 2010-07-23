require 'sinatra'
require 'dm-core'
require 'dm-validations'
require 'appengine-apis/users'
require 'appengine-apis/memcache'
require 'hpricot'

DataMapper.setup(:default, "appengine://auto")

# load models
Dir.glob("models/*.rb").each { |f| require(f) }

# load libs
Dir.glob("lib/*.rb").each { |f| require(f) }
include Auth

# load helpers
Dir.glob("helpers/*.rb").each { |f| require(f) }

# load controllers
Dir.glob("controllers/*.rb").each { |f| require(f) }

require 'erubis'

set :erubis, {:layout => :default}

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

get '/feeds/latest' do
  @articles = Article.all(:limit => 10, :is_public => true)
  unless output = cache.get("rss")
    output = builder(:rss)
    cache.set("rss", output)
    output
  else
    output
  end
end

not_found do
  '404'
end

def cache
  @cache ||= AppEngine::Memcache.new
end

# controllers
include CronController
include PageController
include TagController
include BlogController