module SerpParser
  module Helpers
    private
    # Clean text from extra spaces
    # @param text [String]
    # @return [String]
    def clean_text(text)
      text.gsub(/\s+/, " ").strip
    end
  end
end
