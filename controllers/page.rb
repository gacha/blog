module PageController 
  get '/:slug/' do
    unless output = cache.get(params[:slug])
      @page = Page.get(params[:slug])
      halt 404 unless @page
      output = erubis(:'page/show')
      @cache.set(params[:slug],output)
      output
    else
      output
    end
  end

  get '/:slug/edit' do
    authorize
    @page = Page.get(params[:slug])
    @page = Page.new(:slug => params[:slug]) unless @page
    erubis :'page/new'
  end

  post '/:slug/update' do
    authorize
    @page = Page.get(params[:slug])
    if params[:page]
      params[:page][:is_public] = false unless params[:page][:is_public]
      params[:page][:enable_comments] = false unless params[:page][:enable_comments]
    end
    if @page
      if @page.update(params[:page])
        redirect @page.url
      else
        erubis :'page/new'
      end
    else
      @page = Page.create(params[:page])
      if @page.saved?
        redirect @page.url
      else
        erubis :'page/new'
      end
    end
  end

  get '/:slug/destroy' do
    authorize
    @page = Page.get(params[:slug])
    halt 404 unless @page
    erubis :'page/destroy'
  end

  post '/:slug/destroy' do
    authorize
    @page = Page.get(params[:slug])
    halt 404 unless @page
    @page.destroy!
    redirect '/'
  end
  
  post '/page/preview' do
    authorize
    @page = Page.new(params[:page])
    erubis :'page/show', :layout => false
  end
end
