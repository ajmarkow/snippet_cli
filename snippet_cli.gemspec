require_relative 'lib/snippet_cli/version'

Gem::Specification.new do |spec|
  spec.name          = "snippet_cli"
  spec.license       = "MIT"
  spec.version       = SnippetCli::VERSION
  spec.authors       = ["AJ Markow"]
  spec.email         = ["alexanderjmarkow@gmail.com"]

  spec.summary       = "Allows you to add snippets to Espanso Config from CLI"
  spec.description   = "You can write to your espanso config directly using this gem"
  spec.homepage      = "https://github.com/ajmarkow/snippet_cli"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")
  spec.add_runtime_dependency "tty-prompt"
  spec.add_runtime_dependency "tty-box"
  spec.add_runtime_dependency "tty-platform"
  spec.add_runtime_dependency "tty-markdown"
  spec.add_runtime_dependency "pastel"
  spec.add_runtime_dependency "bundler"
  spec.add_runtime_dependency "snippets_for_espanso"
  spec.add_runtime_dependency "httparty"
  spec.add_runtime_dependency "ascii"


  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ajmarkow/snippet_cli"
  spec.metadata["changelog_uri"] = "https://github.com/ajmarkow/snippet_cli"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
