module SerpParser
  module Helpers
    private
    # Clean text from extra spaces
    # @param text [String]
    # @return [String]
    def clean_text(text)
      text.gsub(/\s+/, " ").strip
    end

    # Remove span elements from description
    # @param element [Nokogiri::XML::Element]
    # @return [String]
    def remove_span_elements(element)
      element&.children&.each { |child| child.remove if child.element? && child.name == "span" && !child.classes.empty? }
    end
  end
end
