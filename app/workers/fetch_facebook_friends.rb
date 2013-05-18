class FetchFacebookFriends
  include Sidekiq::Worker

  def perform user_id
    user = User.find(user_id)
  end
end