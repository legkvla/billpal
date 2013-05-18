module ApplicationHelper
  def hide_controls?
    !current_user.present? || payment_controller?
  end
end
