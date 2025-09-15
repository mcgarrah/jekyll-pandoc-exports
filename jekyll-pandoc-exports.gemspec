require_relative "lib/jekyll-pandoc-exports/version"

Gem::Specification.new do |spec|
  spec.name          = "jekyll-pandoc-exports"
  spec.version       = Jekyll::PandocExports::VERSION
  spec.authors       = ["Michael McGarrah"]
  spec.email         = ["mcgarrah@gmail.com"]

  spec.summary       = "Jekyll plugin to generate DOCX and PDF exports using Pandoc"
  spec.description   = "Automatically generate Word documents and PDFs from Jekyll pages with configurable options, Unicode cleanup, and auto-injected download links."
  spec.homepage      = "https://github.com/mcgarrah/jekyll-pandoc-exports"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*", "bin/*", "README.md", "LICENSE", "CHANGELOG.md"]
  spec.require_paths = ["lib"]
  spec.executables   = ["jekyll-pandoc-exports"]

  spec.required_ruby_version = ">= 2.6.0"

  spec.add_dependency "jekyll", ">= 3.0"
  spec.add_dependency "pandoc-ruby", "~> 2.1"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end