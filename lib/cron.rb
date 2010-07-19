module Cron
  # holds all cron jobs
  module Jobs
    def self.aggregator
      aggregator = Aggregator.new
      aggregator.clear_cache
      aggregator.load_flickr_images
      aggregator.load_tweets
      aggregator.load_bookmarks
    end
  end
  
  # runs cron job by name
  def self.run name
    if Cron::Jobs.respond_to?(name)
      Cron::Jobs.send(name)
    end
  end
end
