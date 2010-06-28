require 'maruku'
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

  def body_as_html
    doc = Maruku.new(self.body)
    doc.to_html
  end

  private

  def slugify(context = :default)
    unless self.slug
      self.slug = self.title.to_s.gsub(/\s/,'-').downcase.gsub(/./){|s| {
        'ā'=>'a','č'=>'c','ē'=>'e','ģ'=>'g','ī'=>'i','ķ'=>'k','ļ'=>'l','ņ'=>'n','š'=>'s','ū'=>'u','ž'=>'z',
        'Ā'=>'A','Č'=>'c','Ē'=>'E','Ģ'=>'G','Ī'=>'I','Ķ'=>'K','Ļ'=>'L','Ņ'=>'N','Š'=>'S','Ū'=>'U','Ž'=>'Z'
      }[$&] || $& }.gsub(/[^\w\s\-]+/i,'')
    end
  end

end
