module ApplicationHelper
  def gravatar_url email, size = 24
    hash = Digest::MD5.hexdigest email.strip.downcase
    "http://www.gravatar.com/avatar/#{hash}?s=#{size}"
  end

  def payment_controller?
    self.is_a?(TransfersController)
  end

  def hide_controls?
    !current_user.present? || payment_controller?
  end
end
