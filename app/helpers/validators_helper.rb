module ValidatorsHelper
  def valid_phone? number
    if number.present?
      (number = number.gsub(/[^0-9\+]/, '')) && number =~ /\A(\+)?(7|8)?\d{10}\z/
    end
  end
end
