module ArticleHelper
  def update_url article
    article.saved? ? "/blog/#{article.id}/update" : '/blog/create'
  end

  def tags_as_html tags
    tags.map{|tag| %^<a href="/blog/tag/#{tag}/">#{tag}</a>^}.join(", ")
  end
end