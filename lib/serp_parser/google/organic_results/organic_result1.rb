module SerpParser
  module Google
    module OrganicResults
      class OrganicResult1 < SerpParser::Google::Search
        include SerpParser::Google::OrganicResults::Shared
        include SerpParser::Helpers

        SELECTOR = "div.g.Ww4FFb"

        def description
          clean_text @doc.css(".VwiC3b").text
        end
      end
    end
  end
end
