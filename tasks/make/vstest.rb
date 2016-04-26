class Make
	def vstest
		t = VsTest.new()
		
		yield t if block_given?
		
		t.execute
	end
end

class VsTest
	attr_accessor :assemblies, :options, :paths, :settings_file
	
	def initialize()
		@options=[]
		@assemblies=[]
		@tests=[]

		@paths = [ 
			{:version => "2013_x86", :path => "C:/Program Files (x86)/Microsoft Visual Studio 12.0/Common7/IDE/CommonExtensions/Microsoft/TestWindow/vstest.console.exe"}		
		]
	end
	
	def get_command_parameters
		command_params = []
		command_params << @options.join(" ") unless @options.nil?
		command_params << @assemblies.map{|asm| "\"#{asm}\""}.join(" ") unless @assemblies.nil?
		command_params << "/settings:\"#{@settings_file}\"" unless @settings_file.nil?
		command_params.join(" ")
	end
  
	def execute
		command_params = get_command_parameters
		sh "#{vstest_path} #{command_params}" 
	end

	def vstest_path
		@paths.each do |p|
			if (File.exist?(p.path))
				logger.info "Running VSTEST #{p.version}: #{p.path}"
				return p.path
			end
		end
		logger.error "Could not find VSTEST in any of the default locations"
	end
	
	def path(value)
		@paths.insert(0, {:version => "user defined", :path => value})
	end
end
