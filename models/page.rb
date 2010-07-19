class Page
  include DataMapper::Resource
	property :title, String, :length => 150, :required => true
	property :slug, String, :key => true, :length => 200, :required => true
	property :body, Text, :required => true
	property :modify_date, Time
	property :is_public, Boolean, :default => false
	property :enable_comments, Boolean, :default => false

  before :valid?, :slugify
  after :save, :clear_cache
  default_scope(:default).update(:order => [:modify_date.desc])

  validates_uniqueness_of :slug

  def url
    '/%s/' % self.slug
  end

  private

  def slugify(context = :default)
    self.slug = to_slug(self.title) unless self.slug
  end

  def clear_cache
    @cache ||= AppEngine::Memcache.new
    @cache.delete(self.slug)
  end
end