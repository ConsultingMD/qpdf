class QpdfGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.file "qpdf.rb", "config/initializers/qpdf.rb"
    end
  end
end
