Sidekiq.configure_server do |config|
  #require 'sidekiq/reliable_fetch'

  ActiveRecord::Base.connection.disconnect!

  rails_config = ActiveRecord::Base.configurations[Rails.env]

  rails_config['reaping_frequency'] = 5
  rails_config['pool'] = Sidekiq.options[:concurrency].to_i * 2

  ActiveRecord::Base.establish_connection
end
