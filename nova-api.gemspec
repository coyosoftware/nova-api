
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "nova/api/version"

Gem::Specification.new do |spec|
  spec.name          = "nova-api"
  spec.version       = Nova::API::VERSION
  spec.authors       = ["Coyô Software"]
  spec.email         = ["ti@coyo.com.br"]

  spec.summary       = %q{Nova.Money API gem}
  spec.description   = %q{This gem was designed to be used as an easy way to comunicate with the Nova.Money API}
  spec.homepage      = "https://app.swaggerhub.com/apis-docs/coyosoftware/Nova.Money/v1"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/coyosoftware/nova-api"
    spec.metadata["changelog_uri"] = "https://github.com/coyosoftware/nova-api/blob/master/CHANGELOG.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.required_ruby_version = ">= 2.5.0"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2"
  spec.add_development_dependency "rake", "~> 13"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "simplecov", "~> 0.21"
  spec.add_development_dependency "byebug", "~> 11.1.3"
  spec.add_development_dependency "webmock", "~> 3.11.2"
  spec.add_development_dependency "rspec-dry-struct", "~> 0.1"

  spec.add_dependency "httparty", "~> 0.1"
  spec.add_dependency "dry-struct", "~> 1.6"
  spec.add_dependency "dry-types", "~> 1.7"
end
