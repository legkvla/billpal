module ValidatorsHelper
  def valid_phone? number
    if number.present?
      (number = number.gsub(/[^0-9\+]/, '')) && number =~ /\A(\+)?(7|8)?\d{10}\z/
    end
  end

  def valid_email? email
    if email.present?
      email =~ /\A(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})\z/i
    end
  end
end
