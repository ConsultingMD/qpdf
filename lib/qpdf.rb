require 'logger'
require 'digest/md5'
require 'rbconfig'
require RbConfig::CONFIG['target_os'] == 'mingw32' && !(RUBY_VERSION =~ /1.9/) ? 'win32/open3' : 'open3'
require 'active_support/core_ext/class/attribute_accessors'

begin
  require 'active_support/core_ext/object/blank'
rescue LoadError
  require 'active_support/core_ext/blank'
end

class Qpdf
  EXE_NAME = "qpdf"
  @@config = {}
  cattr_accessor :config

  def initialize(execute_path = nil)
    @exe_path = execute_path || find_binary_path
    raise "Location of #{EXE_NAME} unknown" if @exe_path.empty?
    raise "Bad location of #{EXE_NAME}'s path" unless File.exists?(@exe_path)
    raise "#{EXE_NAME} is not executable" unless File.executable?(@exe_path)
  end

  def unlock(source_file, unlocked_file, password = nil)
    command = "#{@exe_path} --decrypt --password='#{password}' '#{source_file}' '#{unlocked_file}'"
    err = Open3.popen3(command) do |stdin, stdout, stderr|
      stderr.read
    end
  rescue Exception => e
    raise "Failed to execute:\n#{command}\nError: #{e}"
  end

  def lock(source_file, locked_file, user_password, owner_password, key_length = 40)
    command = "#{@exe_path} --encrypt #{user_password} #{owner_password} #{key_length} -- '#{source_file}' '#{locked_file}'"
    err = Open3.popen3(command) do |stdin, stdout, stderr|
      stderr.read
    end
  rescue Exception => e
    raise "Failed to execute:\n#{command}\nError: #{e}"
  end

  private

    def find_binary_path
      possible_locations = (ENV['PATH'].split(':')+%w[/usr/bin /usr/local/bin ~/bin]).uniq
      exe_path ||= Qpdf.config[:exe_path] unless Qpdf.config.empty?
      exe_path ||= possible_locations.map{|l| File.expand_path("#{l}/#{EXE_NAME}") }.find{|location| File.exists? location}
      exe_path || ''
    end
end
