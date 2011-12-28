Gem::Specification.new do |s|
  s.name              = 'private_event'
  s.version           = '0.0.3'
  s.date              = '2011-12-26'

  s.summary     = "Gem hosting and indexing, extracted from the rubygems.org repo"
  s.description = "Gem hosting and indexing, extracted from the rubygems.org repo"

  s.authors  = ["Tom Bombadil"]
  s.email    = 'amanibhavam@destructuring.org'
  s.homepage = 'https://github.com/HeSYINUvSBZfxqA/private_event'

  s.require_paths = %w[lib]

  s.executables = []

  s.add_dependency('sinatra')
  s.add_dependency('fog')
  s.add_dependency('fpm')

  s.files = %w[
    README.md
    MIT-LICENSE
    private_event.gemspec
    config/hostess.ru
    server/repo/.gitignore
  ] + Dir['lib/hostess/**/*'] + Dir['bin/*']
end
