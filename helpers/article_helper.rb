module ArticleHelper
  def update_url article
    article.saved? ? "/blog/#{article.id}/update" : '/blog/create'
  end

  def tags_as_html tags
    tags.map { |tag| %^<a href="/blog/tag/#{tag}/">#{tag}</a>^ }.join(", ")
  end

  def articles_navigation year
    html = []
    if year
      if Article.count_by_year(year.to_i - 1) > 0
        html << %^<a href="/blog/#{year.to_i - 1}">⇦ Vecāki raksti</a>^
      end
      if Article.count_by_year(year.to_i + 1) > 0
        html << %^<a href="/blog/#{year.to_i + 1}">Jaunāki raksti ⇨</a>^
      end
    else
      if Article.count_by_year(Date.today.year - 1) > 0
        html << %^<a href="/blog/#{Date.today.year - 1}">⇦ Vecāki raksti</a>^
      end
    end
    html.join(" | ")
  end
end