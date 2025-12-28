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

    # Extract the URL from a Google redirect URL
    # Handles both "/url?q=" and "/url?sa=...&url=" formats.
    # @param url [String]
    # @return [String, nil]
    def self.clean_google_url(url)
      return if url.nil?
      return url unless url.start_with?("/url?")

      begin
        query = URI.parse(url).query
        params = URI.decode_www_form(query.to_s).to_h
        params["q"] || params["url"] || url
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
  end
end
