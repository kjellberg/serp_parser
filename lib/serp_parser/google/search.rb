module SerpParser
  module Google
    # The Search class parses the HTML for Google search results
    # and extracts specific information based on the provided schema.
    class Search < SerpParser::Parser
      SEARCH_ENGINE = "google"

      # Schema defining the structure and extractor types for the search results.
      SCHEMA = {
        organic_results: {
          type: :collection,
          parsers: [
            SerpParser::Google::OrganicResults::OrganicResult1
          ]
        },
        search_information: {
          type: :hash
        }
      }

      private

      # Builds the accessors for the data hash based on the schema.
      #
      # @return [void]
      def execute_schema
        schema.each do |key, values|
          @data[key] = execute_collection(values[:parsers]) if values[:type] == :collection
          @data[key] = self.send(key) if values[:type] == :instance_method
          @data[key] = {} if values[:type] == :hash
        end
      end

      def execute_collection(parsers)
        parsers.flat_map do |parser|
          @doc.css(parser::SELECTOR).map.with_index do |element, index|
            parser.new(element.inner_html).processed_data
          end
        end
      end
    end
  end
end
