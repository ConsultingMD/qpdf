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

  #  Write each page to a separate output file. Output file names are generated as follows:
  #  - If the string %d appears in the output file name, it is replaced with a range of zero-padded page numbers starting from 1.
  #  - Otherwise, if the output file name ends in .pdf (case insensitive), a zero-padded page range, preceded by a dash, is inserted before the file extension.
  #  - Otherwise, the file name is appended with a zero-padded page range preceded by a dash.
  # @param [String] source_file path of source pdf
  # @param [String] dest_filename output file name (see above)
  # @return [Array] list of filenames for generated output files
  def split_pages(source_file, dest_filename)
    dest_filename_before = ''
    dest_filename_after = ''
    if dest_filename.include? '%d'
      dest_filename_parts = dest_filename.split('%d')
      dest_filename_before = dest_filename_parts.first
      dest_filename_after = dest_filename_parts.last
    elsif dest_filename.downcase.end_with '.pdf'
      dest_filename_parts = dest_filename.rpartition('.')
      dest_filename_before = "#{dest_filename_parts.first}-"
      dest_filename_after = '.pdf'
    else
      dest_filename_before = "#{dest_filename}-"
    end

    command = "#{@exe_path} --split-pages '#{source_file}' '#{dest_filename}'"
    num_pages = num_pages source_file
    num_pages_digits = num_pages.to_s.length

    dest_files = (1..num_pages).map do |page_no|
      page_no_str = page_no.to_s.rjust(num_pages_digits, '0')
      "#{dest_filename_before}#{page_no_str}#{dest_filename_after}"
    end

    _, error_str, status = Open3.capture3(command)
    raise "Error: #{error_str}" unless status.success?
    dest_files
  end

  def num_pages(source_file)
    command = "#{@exe_path} --show-npages '#{source_file}'"
    output_str, error_str, status = Open3.capture3(command)
    raise "Error: #{error_str}" unless status.success?
    output_str.to_i
  end

  private

  def find_binary_path
    possible_locations = (ENV['PATH'].split(':')+%w[/usr/bin /usr/local/bin ~/bin]).uniq
    exe_path ||= Qpdf.config[:exe_path] unless Qpdf.config.empty?
    exe_path ||= possible_locations.map{|l| File.expand_path("#{l}/#{EXE_NAME}") }.find{|location| File.exists? location}
    exe_path || ''
  end
end
