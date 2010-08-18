class Aggregator
  def initialize
    @cache = AppEngine::Memcache.new
  end

  def clear_cache
    @cache.delete(:flickr)
    @cache.delete(:tweets)
    @cache.delete(:bookmarks)
  end

  def load_flickr_images
    unless images = @cache.get(:flickr)
      begin
        data = AppEngine::URLFetch.fetch "http://api.flickr.com/services/feeds/photos_public.gne?id=30514851@N00&lang=en-us&format=rss_200"
        doc = Hpricot.XML(data.body)
        images = doc.search("//item").collect{|item| {:title => item.search("media:description").inner_html.gsub(/&lt;\/[a-z]{1}&gt;/,'').gsub(/&lt;[a-z]{1}&gt;/,''),:thumb => item.search("media:thumbnail").attr("url"),:big=>item.search("media:thumbnail").attr("url").gsub(/_s\.jpg/,'_z.jpg'),:link=>item.search("title").inner_html}}
        @cache.set(:flickr,images) unless images.empty?
      rescue
        return []
      end
    end
    images
  end

  def load_tweets
    unless tweets = @cache.get(:tweets)
      begin
        data = AppEngine::URLFetch.fetch "http://www.ithouse.lv/proxy/twitter.php?screen_name=gacha&count=10"
        doc = Hpricot.XML(data.body)
        tweets = doc.search("//status").collect{|item| {:body => item.search("text").inner_html,:time => Time.parse(item.search("created_at").inner_html)}}
        @cache.set(:tweets,tweets) unless tweets.empty?
      rescue
       return []
      end
    end
    tweets
  end

  def load_bookmarks
    unless bookmarks = @cache.get(:bookmarks)
      begin
        data = AppEngine::URLFetch.fetch "http://feeds.delicious.com/v2/rss/gacha_lv?count=15"
        doc = Hpricot.XML(data.body)
        bookmarks = doc.search("//item").collect{|item| {:title => item.search("title").inner_html,:link => item.search("link").inner_html}}
        @cache.set(:bookmarks,bookmarks) unless bookmarks.empty?
      rescue
        return []
      end
    end
    bookmarks
  end
end
