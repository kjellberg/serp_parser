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

      execute_schema
    end

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
          parser.new(element).processed_data
        end
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
