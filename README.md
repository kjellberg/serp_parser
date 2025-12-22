# serp_parser

Ruby toolkit for parsing Google Search HTML result pages offline. Feed it a saved search result page (no live HTTP required) and it returns structured organic results with titles, descriptions, URLs, domains, dates, ratings, and sitelinks—ordered exactly as they appeared on the page.

## Requirements
- Ruby 2.6+
- Bundler

## Install
From the repo:
```bash
bundle install
```

Use it in another project (until published to RubyGems):
```ruby
# Gemfile
gem "serp_parser", git: "https://github.com/kjellberg/serp_parser"
```

## Quickstart: parse a Google HTML result page
```ruby
require "serp_parser"
require "json"

html = File.read("spec/files/google/full_html_response.html") # any saved Google SERP HTML
parser = SerpParser::Google::Search.new(html)

# Work with Ruby objects
results = parser.organic_results
puts results.first.title       # => "Presidents | The White House"
puts results.first.position    # => 1
puts results.first.site_links.map(&:title)

# Export to a plain Hash/JSON
puts JSON.pretty_generate(parser.to_h)
```

The `SerpParser::Google::Search` class reads the HTML and returns a `SerpParser::Collection` of `SerpParser::Models::OrganicResult` objects. Positions are assigned automatically based on on-page order.

### Output shape
Each organic result responds to:
- `title`, `description`, `url`, `domain`
- `date` (ISO8601 or `nil`)
- `rating` (`{"score","max_score","number_of_ratings"}` or `nil`)
- `site_links` (collection of `title`, `url`, `position`)
- `position` (1-based)

Example JSON fragment:
```json
{
  "organic_results": [
    {
      "position": 1,
      "title": "Presidents | The White House",
      "description": "Presidents · George Washington · John Adams ...",
      "domain": "whitehouse.gov",
      "url": "https://www.whitehouse.gov/about-the-white-house/presidents/",
      "date": null,
      "rating": null,
      "site_links": [
        { "position": 1, "title": "Joe Biden", "url": "https://www.whitehouse.gov/administration/president-biden/" }
      ]
    }
  ]
}
```

## How it works (roughly)
- HTML is parsed with Nokogiri into a fragment.
- A schema-driven parser walks organic result selectors (`div.g.Ww4FFb`, `div.Gx5Zad.xpd.EtOod.pkphOe`, etc.).
- Each result type extracts fields, sanitizes Google redirect URLs, and normalizes ratings/dates.
- Collections assign `position` in document order.

Selectors are tuned to the markup seen in the included fixture pages from September 2024. If Google changes its HTML, adjust the selectors under `lib/serp_parser/google/organic_results/`.

## Samples and tests
- Sample SERP pages live in `spec/files/google/`.
- Expected outputs per result type are stored as JSON alongside the fixtures.
- Run the full suite:
```bash
bundle exec rspec
```

## Tips
- Always save the full HTML (including inline scripts/styles) before parsing.
- If you see missing fields, inspect the fixture’s DOM and tweak the selectors or allowed elements lists in the relevant parser class.

