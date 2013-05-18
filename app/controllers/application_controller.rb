class ApplicationController < ActionController::Base
  include ApplicationHelper

  protect_from_forgery

  before_filter :set_git_version

  layout :detect_layout

  private

  def set_git_version
    response.headers['X-Git-Revision'] = GIT_HASH
  end

  def detect_layout
    if self.is_a?(DeviseController) || payment_controller?
      'only_topbar'
    else
      'layout'
    end
  end
end
