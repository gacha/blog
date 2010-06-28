module ArticleHelper
  def update_url article
    article.saved? ? "/blog/#{article.id}/update" : '/blog/create'
  end
end