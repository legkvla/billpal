module ApplicationHelper
  def gravatar_url email, size = 24
    hash = Digest::MD5.hexdigest email.strip.downcase
    "http://www.gravatar.com/avatar/#{hash}?s=#{size}"
  end

  def money_string money, precision = 0
    number_to_currency(money.to_f, precision: precision, unit: 'p', format: '%n%u')
  end
end
