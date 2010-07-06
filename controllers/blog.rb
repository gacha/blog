require 'controllers/auth.rb'

module BlogController
  include Auth

  get '/blog/' do
    @articles = Article.all(:is_public => true)
    erubis :'blog/index'
  end

  get '/blog/list' do
    authorize
    @articles = Article.all
    erubis :'blog/list'
  end

  get '/blog/:day/:month/:year/:slug/' do
    @article = Article.first(:create_date => (Time.local(params[:year],params[:month],params[:day],0,0)..Time.local(params[:year],params[:month],params[:day],23,59)), :slug => params[:slug])
    halt 404 unless @article
    erubis :'blog/show'
  end

  get '/blog/new' do
    authorize
    @article = Article.new(:is_public => true, :enable_comments => true)
    erubis :'blog/new'
  end

  post '/blog/create' do
    authorize
    if params[:article]
      @article = Article.new(params[:article])
      @article.author = user
      if @article.valid?
        @article.save
        redirect @article.url
      else
        erubis :'blog/new'
      end
    end
  end

  get '/blog/:id/edit' do
    authorize
    @article = Article.get(params[:id])
    halt 404 unless @article
    erubis :'blog/new'
  end

  post '/blog/:id/update' do
    authorize
    @article = Article.get(params[:id])
    halt 404 unless @article
    if params[:article]
      params[:article][:is_public] = false unless params[:article][:is_public]
      params[:article][:enable_comments] = false unless params[:article][:enable_comments]
    end
    if @article.update(params[:article])
      redirect @article.url
    else
      erubis :'blog/new'
    end
  end

  get '/blog/:id/destroy' do
    authorize
    @article = Article.get(params[:id])
    halt 404 unless @article
    erubis :'blog/destroy'
  end

  post '/blog/:id/destroy' do
    authorize
    @article = Article.get(params[:id])
    halt 404 unless @article
    @article.destroy!
    redirect '/blog/list'
  end
end