class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_git_version

  private

  def set_git_version
    response.headers['X-Git-Revision'] = GIT_HASH
  end
end
