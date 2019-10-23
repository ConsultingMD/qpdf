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
  EXE_NAME = 'qpdf'
  @@config = {}
  cattr_accessor :config

  def initialize(execute_path = nil)
    @exe_path = execute_path || find_binary_path
    raise "Location of #{EXE_NAME} unknown" if @exe_path.empty?
    raise "Bad location of #{EXE_NAME}'s path" unless File.exist?(@exe_path)
    raise "#{EXE_NAME} is not executable" unless File.executable?(@exe_path)
  end

  def unlock(source_file, unlocked_file, password = nil)
    command = "#{@exe_path} --decrypt --password='#{password}' '#{source_file}' '#{unlocked_file}'"
    _, error_str, status = Open3.capture3(command)
    raise "Error: #{error_str}" unless status.success?
  end

  def lock(source_file, locked_file, user_password, owner_password, key_length = 40)
    command = "#{@exe_path} --encrypt #{user_password} #{owner_password} #{key_length} -- '#{source_file}' '#{locked_file}'"
    _, error_str, status = Open3.capture3(command)
    raise "Error: #{error_str}" unless status.success?
  end

  private

  def find_binary_path
    possible_locations = (ENV['PATH'].split(':')+%w[/usr/bin /usr/local/bin ~/bin]).uniq
    exe_path ||= Qpdf.config[:exe_path] unless Qpdf.config.empty?
    exe_path ||= possible_locations.map{|l| File.expand_path("#{l}/#{EXE_NAME}") }.find{|location| File.exists? location}
    exe_path || ''
  end
end
