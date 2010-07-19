require 'sinatra'
require 'dm-core'
require 'dm-validations'
require 'appengine-apis/users'
require 'appengine-apis/memcache'
require 'hpricot'

DataMapper.setup(:default, "appengine://auto")

# load models
Dir.glob("models/*.rb").each {|f| require(f) }

# load libs
Dir.glob("lib/*.rb").each {|f| require(f) }
include Auth

# load helpers
Dir.glob("helpers/*.rb").each {|f| require(f) }

# load controllers
Dir.glob("controllers/*.rb").each {|f| require(f) }

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
    cache.set("rss",output)
    output
  else
    output
  end
end

get '/import/blog/' do
  authorize
  data = AppEngine::URLFetch.fetch "http://gacha.id.lv/blog/"
  doc = Hpricot(data.body)
  articles = doc.search("div .article")
  articles.collect{|article| {:title => article.search(".article-title a").text, :url => article.search(".article-title a").attr(:href), :body => article.search(".article-body").inner_html,:tags => article.search(".article-header a").map(&:inner_html)}}.each do |item|
    article = Article.new
    article.title = item[:title]
    article.body = item[:body]
    article.tags = item[:tags]
    item[:url] =~ /\/blog\/(\d+)\/(\d+)\/(\d+)\/.+\//
    article.create_date = Time.local($3,$2,$1)
    article.author = current_user
    article.is_public = true
    if article.valid?
      article.save
    else
      puts article.errors.inspect
    end
  end
  "Imported #{articles.size} articles"
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