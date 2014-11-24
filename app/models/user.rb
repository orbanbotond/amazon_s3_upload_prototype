class User < ActiveRecord::Base
  mount_uploader :avatar, ImageUploader

  def process_image(key)
    Worker.perform_async(self.id, key)
  end

  def image_name
    File.basename(image.path || image.filename) if image
  end

  class Worker
    include Sidekiq::Worker
    
    def perform(id, key)
      binding.pry
      u = User.find id
      u.key = key
      u.remote_avatar_url = key
      u.save!
      u.update_column(:image_processed, true)
    end
  end
end
