# -*- encoding: utf-8 -*-
# stub: snippets_for_espanso 0.1.2 ruby lib

Gem::Specification.new do |s|
  s.name = "snippets_for_espanso".freeze
  s.version = "0.1.2".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "source_code_uri" => "https://github.com/ajmarkow/snippets_for_espanso" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["AJ Markow".freeze]
  s.date = "2020-12-19"
  s.description = "Gem with methods to create simple snippets, or more complex snippets which invoke a form on users computer.".freeze
  s.email = "aj@ajm.codes".freeze
  s.homepage = "https://rubygems.org/gems/snippets_for_espanso".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.3".freeze
  s.summary = "Takes strings & writes YAML to a file in the format for Espanso Text Expander.".freeze

  s.installed_by_version = "3.7.2".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<yaml>.freeze, [">= 0".freeze])
end
