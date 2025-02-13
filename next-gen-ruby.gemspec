# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require('next_gen/version')

Gem::Specification.new do |specification|
  specification.name = 'next_gen'
  specification.version = NextGen::VERSION
  specification.authors = ['Stefano Baldazzi']
  specification.email = %w[stefanobaldazzi40@gmail.com]
  specification.description = 'Next-Gen Ruby is a lightweight gem for manage crypto operations.'
  specification.summary = "next-gen-#{specification.version}"
  specification.homepage = 'https://github.com/Baldaz02/next-gen-ruby'
  specification.license = 'MIT'

  specification.required_ruby_version = '>= 2.7'

  specification.files = Dir['lib/**/*']
  specification.files += Dir['fixtures/*']
  specification.files += %w[README.md]
  specification.executables = specification.files.grep(%r{^bin/}) { |file| File.basename(file) }
  specification.require_paths = %w[lib]

  specification.add_dependency('zeitwerk', '~> 2.4')

  specification.add_development_dependency('bump', '~> 0.8')
  specification.add_development_dependency('digest', '~> 3.1.0')
  specification.add_development_dependency('pry', '~> 0.14')
  specification.add_development_dependency('rake', '~> 13.0')
  specification.add_development_dependency('rspec', '~> 3.8')
  specification.add_development_dependency('rubocop', '~> 0.0')
  specification.add_development_dependency('simplecov', '~> 0.16')
  specification.metadata['rubygems_mfa_required'] = 'true'
end
