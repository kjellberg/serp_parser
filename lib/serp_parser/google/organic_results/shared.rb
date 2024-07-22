module SerpParser
  module Google
    module OrganicResults
      module Shared
        SCHEMA = {
          title: {
            type: :instance_method
          },
          description: {
            type: :instance_method
          },
          url: {
            type: :instance_method
          },
          site_links: {
            type: :collection,
            parsers: [
              SerpParser::Google::OrganicResults::SiteLinks::SiteLink1
            ]
          }
        }

        def title
          clean_text @doc.css("h3").text
        end

        # Returns the URL of the result
        # @return [String]
        def url
          href = @doc.css("a").first["href"]
          href.start_with?("/url?q=") ? href.match(%r{/url\?q=(.*?)&})[1] : href
        end

        def processed_data
          SerpParser::Models::OrganicResult.new(**@data)
        end
      end
    end
  end
end
