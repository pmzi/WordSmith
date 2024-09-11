require_relative "version"

Gem::Specification.new do |s|
  s.name        = "word_smith"
  s.version     = WordSmith::VERSION
  s.summary     = "MR Word Smith!"
  s.description = "Command-line tool for quick and easy English word lookup."
  s.authors     = ["Pouya Mozaffar Magham"]
  s.email       = "pouya.mozafar@gmail.com"
  s.files       = ["lib/*"]
  s.homepage    =
    "https://github.com/pmzi/WordSmith"
  s.license       = "MIT"
end