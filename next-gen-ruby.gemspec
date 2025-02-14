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

  specification.add_dependency('csv', '~> 3.3.2')
  specification.add_dependency('json')
  specification.add_dependency('ostruct', '~> 0.6')
  specification.add_dependency('rest-client')
  specification.add_dependency('tzinfo', '~> 2.0.6')
  specification.add_dependency('vcr')
  specification.add_dependency('zeitwerk', '~> 2.4')

  specification.metadata['rubygems_mfa_required'] = 'true'
end
