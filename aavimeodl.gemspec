
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "aavimeodl/version"

Gem::Specification.new do |spec|
  spec.name          = "aavimeodl"
  spec.version       = Aavimeodl::VERSION
  spec.authors       = ["candyapplecorn"]
  spec.email         = ["candyapplecorn@gmail.com"]

  spec.summary       = %q{Downloads private App Academy videos from Vimeo}
  spec.homepage      = "https://github.com/candyapplecorn/aa-vimeo-downloader/tree/youtube-dl_ruby_bindings"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "http://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = ['aavimeodl']
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "byebug", ">=1.0"
  spec.add_runtime_dependency "youtube-dl.rb"
end
