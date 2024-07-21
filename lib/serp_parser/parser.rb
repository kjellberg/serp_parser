module SerpParser
  class Parser
    attr_reader :data

    # Initializes a new instance of the Search class.
    #
    # @param html [String] The raw HTML of the search results page.
    def initialize(html, schema: nil)
      @raw_html = html
      @doc = Nokogiri::HTML(html)
      @data = {}
      @schema = nil

      execute_schema
    end

    private

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
