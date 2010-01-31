class AdBanner < ActiveRecord::Base
  default_scope :order => (Radiant::Config['ad_banners.categories'].blank? ? '' : 'category, ')+'weight ASC, created_at ASC'
  named_scope :displayable, :conditions => ['weight > ?', 0]
  
  belongs_to :asset

  validates_presence_of :name, :asset_id#, :link_url
  validates_format_of :link_url, :allow_blank => true,
                      :with => URI.regexp(['http', 'https']),
                      :message => "doesn't look like a URL"

  def self.select_banner(options = {})
    exclusions = options[:exclude] || []
    
    find_opts = {:select => 'ad_banners.id, weight',
                 :conditions => ['weight > ?', 0]}
    unless options[:category].blank?
      find_opts[:conditions][0] += ' AND category = ?'
      find_opts[:conditions] << options[:category]
    end
    
    weightings = self.find(:all, find_opts).map do |banner|
      [banner.id] * (exclusions.include?(banner.id) ? 0 : banner.weight)
    end.flatten
    find_by_id(weightings[rand(weightings.size)], :include => :asset)
  end

  def image_src( version = nil )
    version = Radiant::Config["ad_banner.asset_version"] if version.nil?
    version = :ad_banner if version.nil?
    version = :original if Asset.thumbnail_sizes[version.to_sym].nil?
    
    self.asset.thumbnail(version.to_sym)
  end
end
