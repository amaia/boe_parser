# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "boe_parser/version"

Gem::Specification.new do |s|
  s.name        = "boe_parser"
  s.version     = BoeParser::VERSION
  s.authors     = ["Amaia Castro"]
  s.email       = ["amaia@amaiac.net"]
  s.homepage    = ""
  s.summary     = %q{BOE parser}
  s.description = %q{A parser for the spanish BOE (Boletín Oficial del Estado - http://boe.es)}

  s.rubyforge_project = "boe_parser"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"

  s.add_runtime_dependency "hpricot"

  s.add_development_dependency "rspec"
end
