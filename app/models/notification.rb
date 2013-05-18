class Notification < ActiveRecord::Base
  attr_accessible :text, :user_id, :viewed

  scope :newest, -> { where(viewed: false) }
end
