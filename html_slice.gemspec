# frozen_string_literal: true

require_relative "lib/html_slice/version"

Gem::Specification.new do |spec|
  spec.name = "html_slice"
  spec.version = HtmlSlice::VERSION
  spec.authors = ["henrique-ft"]
  spec.email = ["hriqueft@gmail.com"]

  spec.summary = "Enable Ruby classes the ability to generate reusable pieces of html"
  spec.description = "Enable Ruby classes the ability to generate reusable pieces of html"
  # spec.homepage = "https://github.com/henrique-ft/html_slice"
  spec.required_ruby_version = ">= 2.5.0"

  # spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/henrique-ft/html_slice"
  spec.metadata["changelog_uri"] = "https://github.com/henrique-ft/html_slice/blob/master/CHANGELOG.md"

  spec.files =
    ["lib/html_slice.rb",
     "lib/html_slice/version.rb"]

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
