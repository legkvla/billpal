Sidekiq.configure_server do |config|
  #require 'sidekiq/reliable_fetch'

  ActiveRecord::Base.establish_connection
end
