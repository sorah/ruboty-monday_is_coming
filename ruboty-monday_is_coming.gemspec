# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruboty-monday_is_coming/version'

Gem::Specification.new do |spec|
  spec.name          = "ruboty-monday_is_coming"
  spec.version       = Ruboty::MondayIsComing::VERSION
  spec.authors       = ["Shota Fukumori (sora_h)"]
  spec.email         = ["her@sorah.jp"]

  spec.summary       = %q{ruboty monday is coming}
  spec.homepage      = "https://github.com/sorah/ruboty-monday_is_coming"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"

  spec.add_dependency "ruboty"
  # spec.add_dependency "nokogiri"
end
