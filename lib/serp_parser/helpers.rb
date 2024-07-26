module SerpParser
  module Helpers
    private
    # Clean text from extra spaces
    # @param text [String]
    # @return [String]
    def clean_text(text)
      text.gsub(/\s+/, " ").strip
    end

    # Extracts a number from a string with a delimiter
    # @param text [String]
    # @return [Float]
    def extract_number(text)
      text.to_s.match(/(\d+[\.,\ ]?\d*)/)[1]
    end

    # Normalizes a number from a string
    # @param string [String]
    # @param decimals [Boolean]
    # @return [Float, Integer]
    def normalize_number(string, decimals: false)
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
    # @return [String]
    def remove_span_elements(element)
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
    # @param url [String]
    # @return [String]
    def clean_google_url(url)
      url.start_with?("/url?q=") ? url.match(%r{/url\?q=(.*?)&})[1] : url
    end
  end
end
