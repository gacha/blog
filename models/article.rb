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
  
  before :valid?, :slugify
  default_scope(:default).update(:order => [:create_date.desc])

  validates_is_unique :slug, :scope => :create_date
  
  def url
    '/blog/%s/%s/' % [self.create_date.strftime("%d/%m/%Y"),self.slug]
  end

  private

  def slugify(context = :default)
    self.slug = to_slug(self.title) unless self.slug
  end

end
