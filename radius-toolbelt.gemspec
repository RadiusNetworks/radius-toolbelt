# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'radius/toolbelt/version'

Gem::Specification.new do |spec|
  spec.name          = "radius-toolbelt"
  spec.version       = Radius::Toolbelt::VERSION
  spec.authors       = ["Radius Networks", "Aaron Kromer", "Christopher Sexton"]
  spec.email         = ["support@radiusnetworks.com"]
  spec.summary       = %q{Radius Networks Tools and Utilities}
  spec.description   = %q{Collection of CLI tools and Rake tasks for common activities.}
  spec.homepage      = "https://github.com/RadiusNetworks/radius-toolbelt"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = %w[ radius ]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w[ lib ]

  spec.required_ruby_version = '~> 2.0'

  spec.add_dependency "rake", "~> 10.0"
  spec.add_dependency "launchy"
  spec.add_dependency "octokit"
  spec.add_dependency "mime-types"


  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rspec"
end
