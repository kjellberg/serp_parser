# frozen_string_literal: true

require "spec_helper"

RSpec.describe SerpParser::Google::Search do
  # Find all 2025-*.html files in spec/files/google/
  serp_files = Dir.glob("spec/files/google/{2025,2026}-*.html").sort

  serp_files.each do |html_file|
    base_name = File.basename(html_file, ".html")
    json_file = html_file.sub(/\.html$/, ".json")

    # Only test files that have matching JSON files
    if File.exist?(json_file)
      include_examples "matches the expected output", "google/#{base_name}"
    end
  end
end
