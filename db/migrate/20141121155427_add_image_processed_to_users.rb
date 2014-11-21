class AddImageProcessedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :image_processed, :boolean
  end
end
