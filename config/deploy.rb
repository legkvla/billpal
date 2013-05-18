require 'bundler/capistrano'

set :application, "billpal"
set :user,        "deploy"
set :ssh_options, { :forward_agent => true }
set :domain,      "billpal.ru"
set :repository,  "git@github.com:wishbear/billpal.git"
set :use_sudo,    false
set :deploy_to,   "/webapps/#{application}"
set :scm,         "git"

role :app, domain
role :web, domain
role :db,  domain, :primary => true

set :rails_env, "production"
default_run_options[:shell] = '/bin/bash --login'

namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
end

after 'deploy:update_code', 'deploy:migrate'
