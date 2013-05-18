module ParsersHelper
  def parse_phone_number phone_number
    if phone_number.present? && (number = phone_number.to_s.gsub(/[^0-9\+]/, '')) && number =~ /\A(\+)?(7|8)?\d{10}\z/
      if number =~ /\A(\+)?(7|8)/
        number.gsub(/\A(\+)?(7|8)/, '+7')
      else
        number
      end
    end
  end
end
