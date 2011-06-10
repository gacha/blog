require 'sinatra'
require 'sinatra/content_for'
require 'dm-core'
require 'dm-validations'
require 'appengine-apis/users'
require 'appengine-apis/memcache'
require 'hpricot'
require 'haml'

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

set :haml, {:layout => :default, :format => :html5}

helpers do
  include AppHelper
  include ArticleHelper
  include Rack::Utils
  alias_method :h, :escape_html

  def render(*args)
    if args.first.is_a?(Hash) && args.first.keys.include?(:partial)
      return haml "_#{args.first[:partial]}".to_sym, :layout => false
    else
      super
    end
  end

end

get '/' do
  aggregator = Aggregator.new
  @flickr = aggregator.load_flickr_images
  @tweets = aggregator.load_tweets
  @delicious = aggregator.load_bookmarks
  haml :index
end

not_found do
  '<h1>404</h1>'
end

def cache
  @cache ||= AppEngine::Memcache.new
end

# controllers
include CronController
include PageController
include BlogController
