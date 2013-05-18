module ApplicationHelper

  def payment_controller?
    self.is_a?(TransfersController)
  end

  def hide_controls?
    !current_user.present? || payment_controller?
  end
end
