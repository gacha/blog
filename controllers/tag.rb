module TagController
  get '/blog/tag/:name/' do
    @articles = Article.all_by_tag params[:name]
    #halt 404 if @articles.empty?
    erubis :'tag/list'
  end
end