module ApplicationHelper
  def hide_controls?
    not current_user.present? or payment_controller?
  end

  def payment_controller?
    case params[:controller]
      when 'transfers' then true
      else false
    end
  end
end
