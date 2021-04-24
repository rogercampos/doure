# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "doure/version"

Gem::Specification.new do |spec|
  spec.name          = "doure"
  spec.version       = Doure::VERSION
  spec.authors       = ["Roger Campos"]
  spec.email         = ["roger@rogercampos.com"]

  spec.summary       = %q{Minimal abstraction to write parameterized filters for ActiveRecord models}
  spec.description   = %q{Minimal abstraction to write parameterized filters for ActiveRecord models}
  spec.homepage      = "https://github.com/rogercampos/doure"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 6.0.0"
  spec.add_dependency "activesupport", ">= 6.0.0"
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end
