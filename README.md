# serp_parser

Ruby toolkit for parsing Google Search HTML result pages offline. Feed it a saved search result page (no live HTTP required) and it returns structured organic results with titles, descriptions, URLs, domains, dates, ratings, sitelinks, and related searches—ordered exactly as they appeared on the page.

## Requirements

- Ruby 2.6+
- Bundler

## Installation

From the repo:
```bash
bundle install
```

Use it in another project (until published to RubyGems):
```ruby
# Gemfile
gem "serp_parser", git: "https://github.com/kjellberg/serp_parser"
```

## Quick Start

```ruby
require "serp_parser"
require "json"

html = File.read("spec/files/google/full_html_response.html") # any saved Google SERP HTML
search = SerpParser::Google::Search.new(html)

# Work with Ruby objects
results = search.organic_results
puts results.first.title       # => "Presidents | The White House"
puts results.first.position    # => 1
puts results.first.site_links.map(&:title)

# Export to a plain Hash/JSON
puts JSON.pretty_generate(search.to_h)
```

## Usage

### Basic Parsing

The `SerpParser::Google::Search` class reads HTML and returns collections of model objects:

```ruby
search = SerpParser::Google::Search.new(html_string)

# Access organic search results
organic_results = search.organic_results  # Returns SerpParser::Collection

# Access related searches (filter pills and "people also ask")
related_searches = search.related_searches  # Returns SerpParser::Collection

# Get everything as a hash
data = search.to_h
```

### Working with Organic Results

Each `OrganicResult` object has the following attributes:

```ruby
result = search.organic_results.first

result.position      # => 1 (1-based index)
result.title         # => "Page Title"
result.description   # => "Page description text"
result.url           # => "https://example.com/page"
result.domain        # => "example.com" (www prefix removed)
result.date          # => "2024-01-15" or nil
result.rating        # => Rating object or nil
result.site_links    # => Array of SiteLink objects or nil
```

#### Rating Objects

Ratings are represented as `SerpParser::Models::OrganicResults::Rating` objects:

```ruby
if result.rating
  result.rating.score              # => 4.5 (Float or nil)
  result.rating.max_score          # => 5 (default: 5)
  result.rating.number_of_ratings  # => 1234 (Integer or nil)
end
```

#### Site Links

Site links (expanded results under an organic result) are available as an array:

```ruby
result.site_links.each do |link|
  link.position  # => 1 (1-based index)
  link.title     # => "Link Title"
  link.url       # => "https://example.com/link"
end
```

### Working with Related Searches

Related searches combine both filter pills and "people also ask" questions. Duplicates are automatically removed:

```ruby
related_searches = search.related_searches

related_searches.each do |search|
  search.query  # => "related search query"
end

# Collections support array-like methods
related_searches.size   # => 6
related_searches.first  # => First RelatedSearch object
related_searches[0]     # => Same as above
related_searches.map(&:query)  # => ["query 1", "query 2", ...]
```

### Working with Collections

Both `organic_results` and `related_searches` return `SerpParser::Collection` objects, which include:

- Array-like access: `collection[0]`, `collection.first`, `collection.last`
- Enumerable methods: `each`, `map`, `select`, `find`, etc.
- Size methods: `size`, `length`, `empty?`
- Position assignment: Positions are automatically assigned based on document order

```ruby
# Iterate over results
search.organic_results.each do |result|
  puts "#{result.position}. #{result.title}"
end

# Filter results
high_rated = search.organic_results.select { |r| r.rating&.score&.>=(4.0) }

# Map to specific attributes
titles = search.organic_results.map(&:title)
domains = search.organic_results.map(&:domain).uniq
```

### Exporting to JSON

Convert everything to a hash and then to JSON:

```ruby
require "json"

data = search.to_h
json_string = JSON.pretty_generate(data)
```

## Output Format

### JSON Structure

```json
{
  "organic_results": [
    {
      "position": 1,
      "title": "Page Title",
      "description": "Page description...",
      "domain": "example.com",
      "url": "https://example.com/page",
      "date": "2024-01-15",
      "rating": {
        "score": 4.5,
        "max_score": 5,
        "number_of_ratings": 1234
      },
      "site_links": [
        {
          "position": 1,
          "title": "Link Title",
          "url": "https://example.com/link"
        }
      ]
    }
  ],
  "related_searches": [
    "related query 1",
    "related query 2"
  ]
}
```

### Notes on Output

- **Ratings**: Returned as `null` if no rating data is available, or a hash with available fields (score, max_score, number_of_ratings)
- **Site Links**: Always an array (empty array `[]` if none exist)
- **Dates**: ISO8601 format string or `null`
- **Related Searches**: Array of query strings (downcased and deduplicated)

## Examples

### Parse a Saved HTML File

```ruby
require "serp_parser"

html = File.read("path/to/google_search_results.html")
search = SerpParser::Google::Search.new(html)

puts "Found #{search.organic_results.size} organic results"
puts "Found #{search.related_searches.size} related searches"
```

### Extract Specific Data

```ruby
# Get all URLs
urls = search.organic_results.map(&:url)

# Get results with ratings
rated_results = search.organic_results.select { |r| r.rating }

# Get all site link titles
site_link_titles = search.organic_results
  .select { |r| r.site_links && !r.site_links.empty? }
  .flat_map { |r| r.site_links.map(&:title) }

# Get related search queries as an array
queries = search.related_searches.map(&:query)
```

### Save Results to JSON

```ruby
require "json"

search = SerpParser::Google::Search.new(html)
File.write("results.json", JSON.pretty_generate(search.to_h))
```

## How It Works

- HTML is parsed with Nokogiri into a document fragment
- A schema-driven DSL configuration defines how to extract different elements and components
- The parser walks the DOM using CSS selectors to find organic results, ratings, sitelinks, and related searches
- Each result type extracts fields, sanitizes Google redirect URLs, and normalizes data
- Collections automatically assign positions based on document order
- Duplicate related searches are automatically removed

Selectors are tuned to the markup seen in the included fixture pages from September 2024 and December 2024. If Google changes its HTML, adjust the selectors under `lib/serp_parser/google/config.rb`.

## Testing

Sample SERP pages live in `spec/files/google/`. Expected outputs per result type are stored as JSON alongside the fixtures.

Run the full test suite:
```bash
bundle exec rspec
```

## Tips

- Always save the full HTML (including inline scripts/styles) before parsing
- If you see missing fields, inspect the fixture's DOM and tweak the selectors in `lib/serp_parser/google/config.rb`
- Related searches automatically deduplicate based on query text
- Collections preserve document order and assign 1-based positions automatically
