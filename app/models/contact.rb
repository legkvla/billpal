class Contact < ActiveRecord::Base
  belongs_to :user

  as_enum :kind, :phone

  validates_presence_of :kind_cd, :user_id, :uid
  validates_uniqueness_of :uid, scope: [:kind_cd]
end
