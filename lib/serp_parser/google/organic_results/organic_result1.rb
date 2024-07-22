module SerpParser
  module Google
    module OrganicResults
      class OrganicResult1 < SerpParser::Google::Search
        include SerpParser::Google::OrganicResults::Shared
        include SerpParser::Helpers

        SELECTOR = "div.g.Ww4FFb"

        # Returns the date of the result
        # @return [Date] iso8601
        def date
          element = @doc.css("span.LEwnzc span")
          return nil unless element.any?

          text = element.text
          Date.parse(text).iso8601
        rescue
          nil
        end

        def description
          element = @doc.css(".VwiC3b")
          element = remove_span_elements(element)
          clean_text element.text
        end
      end
    end
  end
end
