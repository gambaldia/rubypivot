require_relative 'lib/rubypivot/version'

Gem::Specification.new do |spec|
  spec.name          = "rubypivot"
  spec.version       = Rubypivot::VERSION
  spec.authors       = ["hiro utsumi"]
  spec.email         = ["gambaldia@gmail.com"]

  spec.summary       = "A tool to make pivot table arrays for ruby"
  spec.description   = "Transforming a dataset or array of hashes into a spreadsheet-style array"
  spec.homepage      = "https://github.com/gambldia/rubypivot"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  # spec.metadata["changelog_uri"] = ""

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
