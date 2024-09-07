module SerpParser
  module Google
    module OrganicResults
      class OrganicResult2 < SerpParser::Google::Search
        include SerpParser::Google::OrganicResults::Shared
        include SerpParser::Helpers

        # @return [String]
        SELECTOR = "div.Gx5Zad.xpd.EtOod.pkphOe"
        REQUIRED_CHILDREN = [ ".egMi0.kCrYT" ]

        # List of allowed span elements (determined by class name) in the description.
        # @return [Array]
        ALLOWED_DESCRIPTION_ELEMENTS = [ "r0bn4c rQMQod" ]

        # The schema for the organic result.
        # @return [Hash]
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
          date: {
            type: :instance_method
          },
          site_links: {
            type: :collection,
            parsers: [
              SerpParser::Google::OrganicResults::SiteLinks::SiteLink2
            ]
          },
          rating: {
            type: :hash,
            parsers: [
              SerpParser::Google::OrganicResults::Ratings::Rating2
            ]
          }
        }

        # Returns the date of the result
        # @return [Date] iso8601
        def date
          element = @doc.css("div.BNeawe.s3v9rd.AP7Wnd span.r0bn4c.rQMQod")
          return nil unless element.any?

          text = element.text
          Date.parse(text).iso8601
        rescue
          nil
        end

        # Returns the description of the result
        # @return [String]
        def description
          element = @doc.css(".BNeawe.s3v9rd.AP7Wnd")
          element = find_description_text_node(element)
          element = remove_span_elements(element)
          return if element.nil?

          clean_text element.text
        end

        private

        # Find the text node that contains the description text
        # @param element [Nokogiri::XML::Element]
        # @return [Nokogiri::XML::Element]
        def find_description_text_node(element)
          element.reverse_each.find do |node|
            node.children.all? do |child|
              child.text? || (child.element? && child.name == "span" && (child["class"].nil? || child["class"].strip.empty? || ALLOWED_DESCRIPTION_ELEMENTS.include?(child["class"])))
            end
          end
        end
      end
    end
  end
end
