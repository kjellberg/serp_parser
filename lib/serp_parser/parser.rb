module SerpParser
  class Parser
    attr_reader :data

    # Initializes a new instance of the Search class.
    #
    # @param html [String] The raw HTML of the search results page.
    def initialize(html_or_doc, schema: nil)
      if html_or_doc.is_a?(String)
        @doc = Nokogiri::HTML::DocumentFragment.parse(html_or_doc)
      else
        @doc = html_or_doc
      end

      @data = {}
      @schema = nil

      run_schema
    end

    def to_h
      {
        organic_results: organic_results.map(&:to_h)
      }
    end

    private

    # Builds the accessors for the data hash based on the schema.
    #
    # @return [void]
    def run_schema
      schema.each do |key, values|
        if values[:type] == :hash
          default_values = values[:default] || {}
          @data[key] = build_merged_hash(values[:parsers], default_values: default_values)
        elsif values[:type] == :collection
          @data[key] = build_collection(values[:parsers])
        else
          @data[key] = self.send(key)
        end
      end
    end

    # Extracts a collection of data from the document.
    # @param parsers [Array] The parsers to use to extract the data.
    # @return [Array] The collection of data.
    def build_collection(parsers)
      results = parse_children(parsers)
      SerpParser::Collection.new(results)
    end

    # Extracts data from the document and merges it into a single hash.
    # @param parsers [Array] The parsers to use to extract the data.
    # @param default_values [Hash] The default values to use if no data is found.
    # @return [Hash] The merged hash of data.
    def build_merged_hash(parsers, default_values: {})
      default_values = default_values.transform_keys(&:to_s) # Ensure keys are strings

      result = parse_children(parsers).reduce(default_values) do |acc, result|
        acc.merge(result)
      end

      result = result.empty? ? nil : result
      result
    end

    def parse_children(parsers)
      parsers.flat_map do |parser|
        @doc.css(parser::SELECTOR).map do |element|
          if defined?(parser::REQUIRED_CHILDREN) && parser::REQUIRED_CHILDREN.any?
            # Check if the element contains the required child elements (direct children only)
            required_children_exist = parser::REQUIRED_CHILDREN.all? do |child_selector|
              !element.children.css(child_selector).empty?
            end
            next unless required_children_exist
          end

          parser.new(element).processed_data
        end.compact  # Remove nil values resulting from the `next` statement
      end
    end

    def schema
      self.class::SCHEMA
    end

    # Handles missing methods by returning the corresponding data from the @data hash.
    #
    # @param method [Symbol] The name of the missing method.
    # @param args [Array] The arguments passed to the missing method.
    # @param block [Proc] An optional block passed to the missing method.
    # @return [Object, nil] The value from the @data hash or nil if not found.
    def method_missing(method, *args, &block)
      if @data[method]
        @data[method]
      else
        super
      end
    end

    # Determines if the object responds to a missing method.
    #
    # @param method [Symbol] The name of the method.
    # @param include_private [Boolean] Whether to include private methods.
    # @return [Boolean] True if the object responds to the method, false otherwise.
    def respond_to_missing?(method, include_private = false)
      @data[method] || super
    end
  end
end
