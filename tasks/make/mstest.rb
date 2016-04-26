class Make
	def mstest()
		t = MsTest.new()
		
		yield t if block_given?
		
		t.execute
	end
end

class MsTest
	attr_accessor :assemblies, :options, :tests, :paths, :settings_file
	
	def initialize()
		@options=[]
		@assemblies=[]
		@tests=[]

		@paths = [ 
			{:version => "2013_x86", :path => "C:/Program Files (x86)/Microsoft Visual Studio 12.0/Common7/IDE/mstest.exe"},
			{:version => "2011_x86", :path => "C:/Program Files (x86)/Microsoft Visual Studio 11.0/Common7/IDE/mstest.exe"},
			{:version => "2011_x64", :path => "C:/Program Files/Microsoft Visual Studio 11.0/Common7/IDE/mstest.exe"},
			{:version => "2010_x86", :path => "C:/Program Files (x86)/Microsoft Visual Studio 10.0/Common7/IDE/mstest.exe"},
			{:version => "2010_x64", :path => "C:/Program Files/Microsoft Visual Studio 10.0/Common7/IDE/mstest.exe"},
			{:version => "2008_x86", :path => "C:/Program Files (x86)/Microsoft Visual Studio 9.0/Common7/IDE/mstest.exe"},
			{:version => "2008_x64", :path => "C:/Program Files/Microsoft Visual Studio 9.0/Common7/IDE/mstest.exe"}
		]
	end
	
	def get_command_parameters
		command_params = []
		command_params << @options.join(" ") unless @options.nil?
		command_params << @assemblies.map{|asm| "/testcontainer:\"#{asm}\""}.join(" ") unless @assemblies.nil?
		command_params << "/testsettings:\"#{@settings_file}\"" unless @settings_file.nil?
		command_params << @tests.map{|test| "/test:#{test}"}.join(" ") unless @tests.nil?
		command_params.join(" ")
	end

	def update_env_path
		@assemblies.each do |a|
			ap = File.absolute_path(a)
			ENV['PATH'] = ENV['PATH'] + ";" + File.dirname(ap)
		end
	end
  
	def execute
		update_env_path
		command_params = get_command_parameters
		logger.info "#{mstest_path} #{command_params}" 
		sh "#{mstest_path} #{command_params}"
	end

	def mstest_path
		@paths.each do |p|
			if (File.exist?(p.path))
				logger.info "Using MSTEST #{p.version}: #{p.path}"
				return p.path
			end
		end
		logger.error "Could not find MSTEST in any of the default locations"
	end
	
	def path(value)
		@paths.insert(0, {:version => "user defined", :path => value})
	end
end
