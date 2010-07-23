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
  property :tags, List
  
  before :valid?, :slugify
  after :save, :clear_cache

  default_scope(:default).update(:order => [:create_date.desc])

  validates_uniqueness_of :slug, :scope => :create_date

  def url
    '/blog/%s/%s/' % [self.create_date.strftime("%d/%m/%Y"),self.slug]
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
    year ? Article.public(:create_date.gt => Time.local(year,1,1), :create_date.lt => Time.local(year,12,31)) : []
  end

  def self.count_by_year year
    Article.public(:create_date.gt => Time.local(year,1,1), :create_date.lt => Time.local(year,12,31)).count  
  end

  def self.all_by_tag name
    self.public(:tags => name)
  end

  def self.public options={}
    all({:is_public => true}.merge(options))
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
