module ApplicationHelper
  def gravatar_url email, size = 24
    hash = Digest::MD5.hexdigest email.strip.downcase
    "http://www.gravatar.com/avatar/#{hash}?s=#{size}"
  end
end
