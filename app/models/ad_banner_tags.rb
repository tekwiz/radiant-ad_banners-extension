module AdBannerTags
  include Radiant::Taggable
  
  class TagError < StandardError; end

  desc %{
    Selects a banner. A specific banner may be specified with the @name@ attribute, otherwise a random banner is selected.

    A banner will only appear once on a given page unless otherwise forced with the @name@ attribute.

    *Usage:*
    <pre><code><r:ad_banner [name="banner_name"] [version="asset_version"] /></code></pre>
  }
  tag 'ad_banner' do |tag|
    @selected_banners ||= []
    ad_banner = find_ad_banner(tag) || AdBanner.select_banner(:exclude => @selected_banners)
    unless ad_banner.nil?
      @selected_banners << ad_banner.id
      banner_link(ad_banner, tag.attr['version'])
    else
      return nil
    end
  end
  
  desc %{
    The namespace for referencing ad banners.  You may specify the 'name'
    attribute on this tag for all contained tags to refer to that ad banner.  
    
    *Usage:* 
    <pre><code><r:ad_banners [name="ad_banner_title"]>...</r:ad_banners></code></pre>
  }    
  tag 'ad_banners' do |tag|
    tag.locals.ad_banner = AdBanner.find_by_name(tag.attr['name'], :joins => "INNER JOIN assets ON assets.id = ad_banners.asset_id") unless tag.attr.empty?
    tag.expand
  end

  desc %{
    Cycles through all ad banners.  
    This tag does not require the name atttribute, nor do any of its children.
    
    *Usage:* 
    <pre><code><r:ad_banners:each>...</r:ad_banners:each></code></pre>
  }    
  tag 'ad_banners:each' do |tag|
    options = tag.attr.dup
    result = []
    ad_banners = AdBanner.find(:all)
    ad_banners.each do |ad_banner|
      tag.locals.ad_banner = ad_banner
      result << tag.expand
    end
    result
  end
  
  desc %{
    Renders an image link for the ad_banner.
    
    *Usage:* 
    <pre><code><r:ad_banners:image_link [name="banner_name"] [version="asset_version"] /></code></pre>
  }    
  tag 'ad_banners:image_link' do |tag|
    options = tag.attr.dup
    ad_banner = find_ad_banner(tag)
    unless ad_banner.nil?
      banner_link(ad_banner, tag.attr['version'])
    else
      raise TagError, "'name' attribute required"
    end
  end

  private
  
    def find_ad_banner(tag)
      tag.locals.ad_banner || AdBanner.find_by_name(tag.attr['name'], :joins => "INNER JOIN assets ON assets.id = ad_banners.asset_id")
    end
  
    def banner_link( ad_banner, version )
      # The HTML is simple enough to roll by hand instead of sucking in REXML
      result = String.new
      if ad_banner.link_url
        result << %Q{<a href="#{CGI.escapeHTML(ad_banner.link_url)}"}
        result << %Q{ target="#{ad_banner.link_target}"} unless ad_banner.link_target.blank?
        result << '>'
      end
      result << %Q{<img src="#{ad_banner.image_src(version)}" title="#{ad_banner.name}" alt="#{ad_banner.asset.caption || ad_banner.asset.title}" />}
      result << '</a>' if ad_banner.link_url
      return result
    end
end
