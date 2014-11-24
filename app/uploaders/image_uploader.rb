class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWaveDirect::Uploader
  include CarrierWave::RMagick

  storage :fog

  default_content_type  'image/jpeg'

  version :thumb do
    process resize_to_fill: [200, 200]
  end
end
