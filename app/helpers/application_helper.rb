module ApplicationHelper
  def hide_controls?
    !current_user.present? || payment_controller?
  end

  def payment_controller?
    case params[:controller]
      when 'transfers' then true
      else false
    end
  end
end
