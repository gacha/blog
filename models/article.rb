class Article
  include DataMapper::Resource
  property :id, Serial
  property :title, String, :length => 150, :required => true
  property :slug, String, :length => 200, :required => true
  property :body, Text, :required => true
  property :create_date, Time, :default => lambda { |r, p| Time.now }
  property :modify_date, Time
  property :author, User, :required => true
  property :is_public, Boolean, :default => false
  property :enable_comments, Boolean, :default => false
  property :render_as, String, :length => 10, :default => 'markdown'
  property :tags, List

  before :valid?, :slugify
  after :save, :clear_cache

  default_scope(:default).update(:order => [:create_date.desc])

  validates_uniqueness_of :slug, :scope => :create_date

  def url
    '/blog/%s/%s/' % [self.create_date.strftime("%d/%m/%Y"), self.slug]
  end

  def self.all_by_year year
    year = if year
      year
    else
      last = Article.public.first
      if last
        last.create_date.year
      else
        nil
      end
    end
    year ? Article.public(:create_date.gt => Time.local(year, 1, 1), :create_date.lt => Time.local(year, 12, 31)) : []
  end

  def self.count_by_year year
    Article.public(:create_date.gt => Time.local(year, 1, 1), :create_date.lt => Time.local(year, 12, 31)).count
  end

  def self.all_by_tag name
    self.public(:tags => name)
  end

  def self.public options={}
    all({:is_public => true}.merge(options))
  end

  def self.import
    data = AppEngine::URLFetch.fetch "http://gacha.id.lv/blog/"
    doc = Hpricot(data.body)
    articles = doc.search("div .article")
    articles.collect { |article| {
            :title => article.search(".article-title a").text,
            :url => article.search(".article-title a").attr(:href),
            :body => article.search(".article-body").inner_html,
            :tags => article.search(".article-header a").map(& :inner_html)
    }
    }.each do |item|
      article = Article.new
      article.title = item[:title]
      article.body = item[:body]
      article.tags = item[:tags]
      item[:url] =~ /\/blog\/(\d+)\/(\d+)\/(\d+)\/.+\//
      article.create_date = Time.local($3, $2, $1)
      article.author = current_user
      article.is_public = true
      article.render_as = 'html'
      if article.valid?
        article.save
      else
        puts article.errors.inspect
      end
    end
  end

  private

  def slugify(context = :default)
    self.slug = to_slug(self.title) unless self.slug
  end

  def clear_cache
    @cache ||= AppEngine::Memcache.new
    @cache.delete(self.url)
    @cache.delete("articles#{self.create_date.year}")
    @cache.delete("rss")
  end

end
