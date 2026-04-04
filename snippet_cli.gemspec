# frozen_string_literal: true

require_relative 'lib/snippet_cli/version'

Gem::Specification.new do |spec|
  spec.name          = 'snippet_cli'
  spec.version       = SnippetCli::VERSION
  spec.authors       = ['AJ Markow']
  spec.email         = ['alexanderjmarkow@gmail.com']
  spec.license       = 'MIT'

  spec.summary       = 'Interactively build snippets for Espanso'
  spec.description   = 'A tool to build complex Espanso snippets interactively'
  spec.homepage      = 'https://github.com/ajmarkow/snippet_cli'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.1.0')

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/ajmarkow/snippet_cli'
  spec.metadata['changelog_uri']   = 'https://github.com/ajmarkow/snippet_cli/blob/master/CHANGELOG.md'
  spec.metadata['github_repo']     = 'ssh://github.com/ajmarkow/snippet_cli'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.force_encoding('UTF-8').split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'clipboard',   '~> 1.3'
  spec.add_dependency 'dry-cli',     '~> 1.0'
  spec.add_dependency 'gum',         '~> 0.3'
  spec.add_dependency 'json_schemer', '~> 2.0'
  spec.add_dependency 'tty-cursor', '~> 0.7'

  spec.add_development_dependency 'aruba', '~> 2.0'
  spec.add_development_dependency 'bundler-audit', '~> 0.9'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.0'
  spec.add_development_dependency 'ruby-lsp', '~> 0.23'
  spec.add_development_dependency 'simplecov', '~> 0.21.2'
end
