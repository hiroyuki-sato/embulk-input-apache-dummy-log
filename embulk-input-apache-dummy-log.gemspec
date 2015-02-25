
Gem::Specification.new do |spec|
  spec.name          = "embulk-input-apache-dummy-log"
  spec.version       = "0.1.0"
  spec.authors       = ["Hiroyuki Sato"]
  spec.summary       = "Apache Dummy Log input plugin for Embulk"
  spec.description   = "Apache Dummy Log input plugin is an Embulk plugin that loads records from Apache Dummy Log so that any output plugins can receive the records. Search the output plugins by 'embulk-output' keyword."
  spec.email         = ["hiroysato@gmail.com"]
  spec.licenses      = ["MIT"]
  spec.homepage      = "https://github.com/hiroyuki-sato/embulk-input-apache-dummy-log"

  spec.files         = `git ls-files`.split("\n") + Dir["classpath/*.jar"]
  spec.test_files    = spec.files.grep(%r{^(test|spec)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', ['~> 1.0']
  spec.add_development_dependency 'rake', ['>= 10.0']
end
