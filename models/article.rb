class Article
  include DataMapper::Resource
	property :title, String, :length => 150, :required => true
	property :slug, String, :key => true, :length => 150
	property :body, Text, :required => true
	property :create_date, Time, :default => lambda { |r, p| Time.now }
	property :modify_date, Time
	property :author, User, :required => true
	property :is_public, Boolean, :default => false
	property :enable_comments, Boolean, :default => true
  
  before :valid?, :slugify

  def url
    '/blog/%s/%s/' % [self.create_date.strftime("%d/%m/%Y"),self.slug]
  end

  private

  def slugify
    self.slug = self.title.to_s.gsub(/\s/,'-').gsub(/^[a-ž_\-0-9]/i,'').downcase unless self.slug
  end
end
