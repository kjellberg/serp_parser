module SerpParser
  module Google
    class Search
      def initialize(html_or_doc, schema: nil)
        if html_or_doc.is_a?(String)
          @doc = Nokogiri::HTML::DocumentFragment.parse(html_or_doc)
          resolve_jsl_dh!(html_or_doc)
        else
          @doc = html_or_doc
        end
        @registry = Config.registry
      end

      def organic_results
        results = Parsers::Element.find_all(@doc, :organic_result, @registry)
        models = results.map do |data|
          SerpParser::Models::OrganicResult.new(**data)
        end
        SerpParser::Collection.new(models)
      end

      def faq_results
        results = Parsers::Element.find_all(@doc, :faq_result, @registry)
        models = results.map do |data|
          SerpParser::Models::FaqResult.new(**data)
        end
        SerpParser::Collection.new(models)
      end

      def sponsored_results
        results = Parsers::Element.find_all(@doc, :sponsored_result, @registry)
        models = results.map do |data|
          SerpParser::Models::SponsoredResult.new(**data)
        end
        SerpParser::Collection.new(models)
      end

      def related_searches
        results = Parsers::Element.find_all(@doc, :related_searches, @registry)
        searches = []
        seen_queries = {}
        results.each do |data|
          if data[:related_searches].is_a?(Array)
            data[:related_searches].each do |search|
              query = search.query
              unless seen_queries.key?(query)
                seen_queries[query] = true
                searches << search
              end
            end
          end
        end
        SerpParser::Collection.new(searches)
      end

      def search_information
        {}
      end

      def to_h
        {
          sponsored_results: sponsored_results.map(&:to_h),
          organic_results: organic_results.map(&:to_h),
          faq_results: faq_results.map(&:to_h),
          related_searches: related_searches.map(&:to_h)
        }
      end

      private

      # Google defers much page content (including FAQ answers) via `jsl.dh(id, html)`
      # calls embedded in <script> tags. This method extracts all those calls, decodes
      # the JS string literals, and injects the HTML into the matching placeholder
      # elements in the already-parsed document. Runs iteratively to handle nesting.
      def resolve_jsl_dh!(raw_html)
        id_map = {}
        raw_html.scan(/jsl\.dh\(['"]([^'"]+)['"]\s*,\s*"((?:[^"\\]|\\.)*)"\s*[,)]/) do |id, content|
          id_map[id] = decode_js_string(content)
        end
        return if id_map.empty?

        10.times do
          changed = false
          @doc.css("[id]").each do |el|
            content = id_map[el["id"]]
            next unless content && el.children.empty?
            el.inner_html = content
            changed = true
          end
          break unless changed
        end
      end

      def decode_js_string(s)
        s
          .gsub(/\\x([0-9a-fA-F]{2})/) { $1.to_i(16).chr(Encoding::UTF_8) }
          .gsub('\\"', '"')
          .gsub("\\\\", "\\")
          .gsub("\\n", "\n")
          .gsub("\\t", "\t")
          .gsub("\\u003c", "<").gsub("\\u003C", "<")
          .gsub("\\u003e", ">").gsub("\\u003E", ">")
          .gsub("\\u0026", "&")
          .gsub("\\'", "'")
      rescue
        s
      end
    end
  end
end
