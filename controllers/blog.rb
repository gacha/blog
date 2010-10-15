module BlogController
  get %r{/blog/(.*)} do |year|
    @year = year =~ /^\d{4}$/ ? year : Date.today.year
    unless output = cache.get("articles#{year}")
      @articles = Article.all_by_year(year)
      output = erubis(:'blog/index')
      cache.set("articles#{year}", output)
      output
    else
      output
    end
  end

  get %r{/feeds/latest(/)?$} do
    @articles = Article.public(:limit => 10)
    unless output = cache.get("rss")
      output = builder(:rss)
      cache.set("rss", output)
      output
    else
      output
    end
  end
  
  get '/blog/import' do
    authorize
    Article.import
    redirect "/blog/"
  end

  get '/blog/list' do
    authorize
    @articles = Article.all
    erubis :'blog/list'
  end

  get '/blog/:day/:month/:year/:slug/' do
    article = Article.public.first(:create_date => (Time.local(params[:year], params[:month], params[:day], 0, 0)..Time.local(params[:year], params[:month], params[:day], 23, 59)), :slug => params[:slug])
    halt 404 unless article
    unless output = cache.get(article.url)
      output = erubis(:'blog/show', :locals => {:article => article, :full => true})
      @cache.set(article.url, output)
      output
    else
      output
    end
  end

  post '/blog/preview' do
    authorize
    erubis :'blog/show', :layout => false, :locals => {:article => Article.new(params[:article])}
  end

  get '/blog/new' do
    authorize
    @article = Article.new(:is_public => true, :enable_comments => true)
    erubis :'blog/new'
  end

  post '/blog/create' do
    authorize
    if params[:article]
      params[:article][:tags] = params[:article][:tags].split(",").map(& :strip) if params[:article][:tags]
      @article = Article.new(params[:article])
      @article.author = current_user
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
      params[:article][:tags] = params[:article][:tags].split(",").map(& :strip) if params[:article][:tags]
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
