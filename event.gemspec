# encoding: utf-8
# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'event/version'

Gem::Specification.new do |spec|
  spec.name          = "event"
  spec.version       = Event::VERSION
  spec.authors       = ["Estante Virutal"]
  spec.email         = ["equipe_ti@estantevirtual.com.br"]
  spec.summary       = %q{Cliente para envio de mensagens.}
  spec.description   = %q{Habilita o uso de mensagaria, afim de estabelecer comunicação com outros módulos da plataforma.}
  spec.homepage      = "http://www.estantevirtual.com.br"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "bunny", ">= 1.7.0"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'

end
