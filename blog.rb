require 'sinatra'
require 'dm-core'
require 'appengine-apis/users'
DataMapper.setup(:default, "appengine://auto")
require 'models/article.rb'
set :haml, {:format => :html5, :layout => :default }

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/' do
  @articles = Article.all
  haml :index
end

post '/save' do
  if params && params[:content]
    a = Article.new(:content => params[:content])
    a.save
    redirect '/'
  end
end
