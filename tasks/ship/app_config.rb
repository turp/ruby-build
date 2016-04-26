require 'build/build'
require 'System.Configuration, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a'

class CaseInsensitiveHash < Hash
  def [](key)
    key.respond_to?(:upcase) ? super(key.upcase) : super(key)
  end

  def []=(key, value)
    key.respond_to?(:upcase) ? super(key.upcase, value) : super(key, value)
  end
end

class AppConfig
	attr_accessor :filename, :connection_strings
	
	def initialize()
		@connection_strings = CaseInsensitiveHash.new
		yield self if block_given?
	end
	
	def execute()
		c = config_file
		
		c.connection_strings.connection_strings.each_with_index do |conn, index|
			if (@connection_strings[conn.name.downcase].nil?)
			
			else
				conn.connection_string = @connection_strings[conn.name.downcase]
			end
		end

		c.save		
	end
	
	def config_file
		fileMap = System::Configuration::ExeConfigurationFileMap.new
		fileMap.exe_config_filename = windowfy(@filename)
		return System::Configuration::ConfigurationManager.open_mapped_exe_configuration(fileMap, System::Configuration::ConfigurationUserLevel.none)
	end
	
end

