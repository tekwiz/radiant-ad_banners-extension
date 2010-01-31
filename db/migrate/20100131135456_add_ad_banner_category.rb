class AddAdBannerCategory < ActiveRecord::Migration
  def self.up
    add_column :ad_banners, :category, :string
  end

  def self.down
    remove_column :ad_banners, :category
  end
end
