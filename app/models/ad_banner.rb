class AdBanner < ActiveRecord::Base
  default_scope :order => 'name ASC'

  belongs_to :asset

  validates_presence_of :name, :asset_id#, :link_url
  validates_format_of :link_url, :allow_blank => true,
                      :with => URI.regexp(['http', 'https']),
                      :message => "doesn't look like a URL"

  def self.select_banner(options = {})
    exclusions = options[:exclude] || []
    weightings = find_by_sql("SELECT ad_banners.id,weight FROM ad_banners INNER JOIN assets ON assets.id = ad_banners.asset_id WHERE weight > 0").map do |banner|
      [banner.id] * (exclusions.include?(banner.id) ? 0 : banner.weight)
    end.flatten
    find_by_id(weightings[rand(weightings.size)])
  end

  def image_src( version = nil )
    version = Radiant::Config["ad_banner.asset_version"].to_sym if version.nil?
    version = :ad_banner if version.nil?
    version = :original if Asset.thumbnail_sizes(version).nil?
    
    ad_banner.asset.thumbnail(version)
  end
end
