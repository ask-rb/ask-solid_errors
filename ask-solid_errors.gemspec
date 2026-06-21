require_relative "lib/ask/solid_errors/version"

Gem::Specification.new do |spec|
  spec.name = "ask-solid_errors"
  spec.version = Ask::SolidErrors::VERSION
  spec.authors = ["Kaka Ruto"]
  spec.email = ["kaka@myrrlabs.com"]

  spec.summary = "SolidErrors — error tracking stored in your Rails database"
  spec.description = "Error context for agents via SolidErrors for the ask-rb ecosystem."
  spec.homepage = "https://github.com/ask-rb/ask-solid_errors"
  spec.license = "MIT"

  spec.required_ruby_version = ">= 3.2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  spec.files = Dir["lib/**/*", "LICENSE", "README.md", "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "ask-core", "~> 0.1"

  spec.add_development_dependency "minitest", "~> 5.25"
  spec.add_development_dependency "mocha", "~> 3.1"
  spec.add_development_dependency "rake", "~> 13.0"
end
