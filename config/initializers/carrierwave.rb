require 'carrierwave/processing/mime_types'

Excon.defaults[:write_timeout] = 50000

CarrierWave.configure do |config|
  subdomain = "billpal-#{Rails.env}"

  case Rails.env
    when 'development', 'production'
      config.storage = :fog

      config.fog_credentials = {
          provider: 'AWS',
          persistent: false,
          aws_access_key_id: 'AKIAIK6HEYLZPYW75IEA',
          aws_secret_access_key: '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',
          region: 'eu-west-1'
      }
      config.fog_attributes = {'Cache-Control' => 'max-age=315576000'}
      config.fog_directory = subdomain
      config.asset_host = "https://#{subdomain}.s3.amazonaws.com"
    when 'test'
      config.storage = :file
      config.enable_processing = false
  end
end
