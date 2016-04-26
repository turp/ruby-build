class Make
	def msbuild
		t = MsBuild.new do |t|
			t.dot_net_version = "v4.0.30319"
		end
	
		yield t if block_given?

		t.execute
	end
end

class MsBuild
	attr_accessor :config, :project_file, :log, :dot_net_version, :verbosity, :noop, :target
	attr_accessor :properties
	
	def initialize()
		@target = 'Default'
		@config = 'Release'
		@verbosity = 'quiet'
		@properties = {}
		yield self if block_given?
	end
	
	def execute()
		logger.info "MSBUILD '#{@project_file}' as '#{@config}' using target '#{@target}'"
		create_log_directory
		cmd = "#{path_to_msbuild} #{get_verbosity} #{get_log} #{get_config} #{get_properties} #{get_target} #{project_file}"
		return if @noop
		sh cmd do |ok, result|
			if not ok
				logger.error(cmd)
				#output = File.open(log, "r").readlines.join("")
				fail "MSBUILD failed with status (#{result.exitstatus}):\n #{result.inspect}"
			end
		end
	end
 
	def whatif
		@noop = true
	end
	
	def create_log_directory()
		return if log.nil?
		
		log_directory = File.dirname(log)
		
		if not Dir.exist?(log_directory)
			Dir.mkdir(log_directory)
		end
	end
	
	def path_to_msbuild
		versions = ["v4.0.30319", "v3.5", "v2.0.50727"]
		path = File.join(ENV['windir'],"Microsoft.NET/Framework")

		@dot_net_version = @dot_net_version || "v4.0.30319"
		
		raise ".Net Framework version #{@dot_net_version} not supported" unless versions.Contains(@dot_net_version)
		raise ".Net Framework version #{@dot_net_version} not installed" unless File.exist?(File.join(path, "#{@dot_net_version}/msbuild.exe"))
		
		File.join(path, "#{@dot_net_version}/msbuild.exe")
	end

	def get_config
		@config.nil? ? "" : "/p:Configuration=#{@config}"
	end
	
	def get_log
		@log.nil? ? "" : "/l:FileLogger,Microsoft.Build.Engine;logfile=#{log}"
	end
	
	def get_target
		@target.nil? ? "" : "/t:#{@target}"
	end
	
	def get_verbosity
		#q[uiet], m[inimal], n[ormal], d[etailed], and diag[nostic]
		return "/verbosity:#{@verbosity}"
	end

	def get_properties
		result = ""

		if (@properties.nil?)
			return result
		end
		
		@properties.each do |key, value|
			result << "/p:#{key}=#{value} "
		end
		
		return result
	 end

end
