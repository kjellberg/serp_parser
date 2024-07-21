# frozen_string_literal: true

require_relative 'lib/serp_parser/version'

Gem::Specification.new do |spec|
  spec.name = 'serp_parser'
  spec.version = SerpParser::VERSION
  spec.authors = [ 'Rasmus Kjellberg' ]
  spec.email = [ '2277443+kjellberg@users.noreply.github.com' ]

  spec.summary = 'Write a short summary, because RubyGems requires one.'
  spec.description = 'Write a longer description or delete this line.'

  spec.homepage = 'https://rankzon.com'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/kjellberg/serp_parser'
  spec.metadata['changelog_uri'] = 'https://github.com/kjellberg/serp_parser/blob/master/CHANGELOG.md'

  spec.files = Dir['lib/**/*', 'MIT-LICENSE', 'README.md']
  spec.require_paths = [ 'lib' ]

  spec.add_dependency 'nokogiri', '~> 1.16'
  spec.add_dependency 'public_suffix', '~> 6.0'
end
