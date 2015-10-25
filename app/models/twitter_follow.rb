class TwitterFollow < ActiveRecord::Base
	belongs_to :user
	validates_presence_of :username
 	validates_uniqueness_of :user_id, :scope => :username

 	scope :recent, ->(limit = 200) { order('created_at desc').limit(200) }

	def self.follow(user, username, hashtag, twitter_user_id)
    entry = TwitterFollow.new
    entry.user_id = user.id
    entry.username = username
    entry.followed_at = DateTime.now
    entry.hashtag = hashtag
    entry.twitter_user_id = twitter_user_id
    entry.save
	end

	def unfollow!
		return if unfollowed
		client = user.credential.twitter_client rescue nil
		client.unfollow(username)
		client.unmute(username)
    update_attributes!({ unfollowed: true, unfollowed_at: DateTime.now })
	end

  def self.get_trending_hashtags(user_id)
    unless Rails.cache.read('twitter_trending_hashtags').present?
      user = User.find user_id
      client = user.credential.twitter_client
      trending = client.trends.map(&:name)
      Rails.cache.write('twitter_trending_hashtags', trending, expires_in: 24.hours)
    end
    return Rails.cache.read('twitter_trending_hashtags')
  end
end
