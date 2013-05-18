class Returns::EmailController < ReturnsController
  def verification_slug
    raise params.inspect
  end
end
