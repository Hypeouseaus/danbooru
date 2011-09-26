module Sources
  module Strategies
    class Pixiv < Base
      attr_reader :artist_name, :profile_url, :image_url, :tags
      
      def self.url_match?(url)
        url =~ /^https?:\/\/(?:\w+\.)?pixiv\.net/
      end
      
      def initialize(url)
        super
      end
      
      def site_name
        "Pixiv"
      end
      
      def unique_id
        image_url =~ /\/img\/([^\/]+)/
        $1
      end
      
      def get
        url = URI.parse(normalized_url).request_uri
        agent.get(url) do |page|
          @artist_name, @profile_url = get_profile_from_page(page)
          @image_url = get_image_url_from_page(page)
          @tags = get_tags_from_page(page)
        end
      end

    protected
      
      def get_profile_from_page(page)
        links = page.search("div.front-subContent a").find_all do |node|
          node["href"] =~ /member\.php/
        end

        if links.any?
          profile_url = "http://www.pixiv.net/" + links[0]["href"]
          children = links[0].children
          artist = children[0]["alt"]
          return [artist, profile_url]
        else
          return []
        end
      end
      
      def get_image_url_from_page(page)
        meta = page.search("meta[property=\"og:image\"]").first
        if meta
          meta.attr("content").sub(/_m\./, ".")
        else
          nil
        end
      end
      
      def get_tags_from_page(page)
        links = page.search("div.pedia li a").find_all do |node|
          node["href"] =~ /tags\.php/
        end

        if links.any?
          links.map do |node|
            [node.inner_text, "http://www.pixiv.net/" + node.attr("href")]
          end
        else
          []
        end
      end
      
      def normalized_url
        @normalized_url ||= begin
          if url =~ /\/(\d+)(_m|_p\d+)?\.(jpg|jpeg|png|gif)/i
            "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=#{$1}"
          elsif url =~ /member_illust\.php/ && url =~ /illust_id=/
            url
          else
            nil
          end
        end
      end
      
      def create_agent
        mech = Mechanize.new

        mech.get("http://www.pixiv.net") do |page|
          page.form_with(:action => "/login.php") do |form|
            form['mode'] = "login"
            form['login_pixiv_id'] = "uroobnad"
            form['pass'] = "uroobnad556"
          end.click_button
        end

        mech
      end
    end
  end
end
