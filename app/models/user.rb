class User < ActiveRecord::Base
  mount_uploader :avatar_url, ImageUploader

  after_save :enqueue_image

  def image_name
    File.basename(image.path || image.filename) if image
  end

  def enqueue_image
    Worker.perform_async(id, key) if !image_processed && key.present?
  end

  class Worker
    include Sidekiq::Worker
    
    def perform(id, key)
      user = User.find(id)
      binding.pry
      user.key = key
      user.remote_avatar_url_url = user.avatar_url.direct_fog_url(with_path: true)
      user.save!
      user.update_column(:image_processed, true)
    end
  end
end
