Gem::Specification.new do |g|
  g.name = 'qpdf'
  g.version = '0.0.1'
  g.date = '2014-03-27'
  g.summary = 'Qpdf library for Rails'
  g.description = 'Qpdf is used for unlocking locked pdf files'
  g.authors = ['Ken Berland', 'Justin Ahn', 'Brett Suwyn']
  g.email = 'ken@grnds.com'
  g.homepage = 'https://github.com/ConsultingMD/qdf.git'
  g.files = %w(README.md)
  g.files += Dir.glob("{lib,generators}/**/*")
  g.require_paths = ['lib']
  g.add_dependency('rails')
  g.add_development_dependency('rake')
end
