require 'controllers/auth.rb'

module Blog
  include Auth

  get '/blog/' do
    @articles = Article.all
    erubis :'blog/index'
  end

  get '/blog/new' do
    authorize
    @article = Article.new
    erubis :'blog/new'
  end

  post '/blog/save' do
    authorize
    if params[:article]
      @article = Article.new(params[:article])
      @article.author = user
      if @article.valid?
        @article.save
        redirect '/blog/'
      else
        erubis :'blog/new'
      end
    end
  end
end