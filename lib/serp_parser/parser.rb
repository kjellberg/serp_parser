module SerpParser
  class Parser
    attr_reader :raw_html

    def initialize(html)
      @raw_html = html
      @doc = Nokogiri::HTML(html)
    end
  end
end
