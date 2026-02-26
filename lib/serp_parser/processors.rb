require "uri"

module SerpParser
  module Processors
    # Clean text from extra spaces
    # @param text [String]
    # @return [String]
    def self.clean_text(text)
      return "" if text.nil?
      # Normalize non-breaking spaces to regular spaces before collapsing
      text.tr("\u00A0", " ").gsub(/\s+/, " ").strip
    end

    # Extracts a number from a string with a delimiter
    # @param text [String]
    # @return [String]
    def self.extract_number(text)
      match = text.to_s.match(/(\d+[\.,\ ]?\d*)/)
      match ? match[1] : ""
    end

    # Normalizes a number from a string
    # @param string [String]
    # @param decimals [Boolean]
    # @return [Float, Integer]
    def self.normalize_number(string, decimals: false)
      fragments = string.to_s.split(/[\.,\ ]/)

      if decimals
        _decimals = fragments.pop
        "#{fragments.join}.#{_decimals}".to_f
      else
        fragments.join.to_i
      end
    end

    # Returns a copy of the node with <style> and <script> children removed,
    # so that .text on the result excludes embedded CSS/JS content.
    # @param element [Nokogiri::XML::Element]
    # @return [Nokogiri::XML::Element]
    def self.strip_inner_style(element)
      return element unless element.respond_to?(:dup)
      clone = Nokogiri::HTML.fragment(element.to_html)
      clone.css("style, script").each(&:remove)
      clone.css('[style*="display:none"]').each(&:remove)
      # Remove AI citation panels, inline citation chips, snippet cards, and source sections
      clone.css(".alk4p, .PxKVs, .wklPJe, .uJ19be, [data-subtree='aimba'], li.ZZh6Vb").each(&:remove)
      clone
    end

    # Remove span elements from description
    # @param element [Nokogiri::XML::Element]
    # @return [Nokogiri::XML::Element]
    def self.remove_span_elements(element)
      return unless element

      # Deep duplicate the element to avoid modifying the original DOM
      duplicate_element = Nokogiri::HTML.fragment(element.to_html)

      # Remove span elements from the duplicate
      duplicate_element.css("span").each do |span|
        span.remove if !span["class"].nil? && !span["class"].empty?
      end

      duplicate_element
    end

    # Extract the URL from a Google redirect URL and strip Google-specific parameters
    # Handles "/url?q=", "/url?sa=...&url=", and "google.com/aclk?...&adurl=" formats.
    # Also removes Google tracking parameters like srsltid, ved, usg, gclid, etc.
    # @param url [String]
    # @return [String, nil]
    def self.clean_google_url(url)
      return if url.nil?

      extracted_url = begin
        if url.start_with?("/url?")
          query = URI.parse(url).query
          params = URI.decode_www_form(query.to_s).to_h
          params["q"] || params["url"] || url
        elsif url.include?("google.com/aclk")
          query = URI.parse(url).query
          params = URI.decode_www_form(query.to_s).to_h
          adurl = params["adurl"]
          if adurl
            # Strip all query params from ad destination URLs — they are all campaign tracking
            uri = URI.parse(URI.decode_www_form_component(adurl))
            uri.query = nil
            uri.to_s
          else
            url
          end
        else
          url
        end
      rescue
        url
      end

      # Discard relative/internal URLs (e.g. /search?q=...)
      return nil if extracted_url.start_with?("/")

      # Strip Google-specific parameters from the URL
      strip_google_params(extracted_url)
    end

    # Strip Google-specific tracking parameters from a URL
    # @param url [String]
    # @return [String]
    def self.strip_google_params(url)
      return url if url.nil? || url.empty?

      begin
        uri = URI.parse(url)
        return url unless uri.query

        # List of Google-specific and UTM tracking parameters to remove
        google_params = %w[
          srsltid ved usg opi sa source rct
          gclid gad_source gad_campaignid gbraid
          utm_source utm_medium utm_campaign utm_content utm_term utm_id utm_name
        ]

        params = URI.decode_www_form(uri.query).reject do |key, _value|
          google_params.include?(key)
        end

        # Rebuild URI without Google parameters
        uri.query = params.empty? ? nil : URI.encode_www_form(params)
        uri.to_s
      rescue
        url
      end
    end

    # Extract text from an element
    # @param element [Nokogiri::XML::Element]
    # @return [String]
    def self.text(element)
      return "" unless element
      element.text
    end

    # Parse date string to ISO8601
    # @param text [String]
    # @return [String, nil] ISO8601 formatted date
    def self.parse_date(text)
      return nil if text.nil? || text.strip.empty?
      Date.parse(text.strip).iso8601
    rescue
      nil
    end

    # Extract score from rating text (e.g., "4.5 · 500 reviews")
    # @param text [String]
    # @return [Float, nil]
    def self.extract_score_from_text(text)
      slices = text.to_s.split(" · ").map { |s| clean_text(s) }
      return nil if slices.empty?
      num_str = extract_number(slices[0])
      normalize_number(num_str, decimals: true)
    end

    # Extract count from rating text (e.g., "4.5 · 500 reviews")
    # @param text [String]
    # @return [Integer, nil]
    def self.extract_count_from_text(text)
      slices = text.to_s.split(" · ").map { |s| clean_text(s) }
      return nil if slices.length < 2
      num_str = extract_number(slices[1])
      normalize_number(num_str)
    end

    # Extract slices from space-separated rating text
    # @param text [String]
    # @return [Array<String>]
    def self.extract_rating_slices(text)
      cleaned = clean_text(text)
      cleaned.split(" ").map { |slice| extract_number(slice) }.compact
    end

    # Extract and decode query parameter from Google search URL
    # @param url [String] URL containing /search?q=...
    # @return [String, nil] Decoded and downcased query string
    def self.extract_query_from_search_url(url)
      return nil if url.nil?

      begin
        # Extract q parameter from URL
        if url.include?("/search?") || url.include?("?q=")
          uri = URI.parse(url)
          params = URI.decode_www_form(uri.query.to_s).to_h
          query = params["q"]

          if query
            # Decode URL encoding and downcase
            decoded = URI.decode_www_form_component(query)
            clean_text(decoded).downcase
          else
            nil
          end
        else
          nil
        end
      rescue
        nil
      end
    end

    # Extract query from text content, removing HTML tags and normalizing
    # @param text [String] Text content that may contain HTML
    # @return [String, nil] Cleaned and downcased query string
    def self.extract_query_from_text(text)
      return nil if text.nil?
      # Clean text, remove extra whitespace, and downcase
      clean_text(text).downcase
    end

    # Extract query from URL or fallback to text
    # Used when URL might be javascript:void(0) or a search URL
    # @param url [String] The href value
    # @param element [Nokogiri::XML::Element] The element to extract text from if URL fails
    # @return [String, nil] Extracted and normalized query
    def self.extract_query_from_url_or_text(url, element = nil)
      # Try to extract from URL first
      query = extract_query_from_search_url(url)
      return query if query

      # Fallback to text content if URL didn't yield a result
      if element
        text = element.at_css("span.dg6jd.JGD2rd")&.text || element.text
        extract_query_from_text(text) if text
      else
        nil
      end
    end
  end
end
