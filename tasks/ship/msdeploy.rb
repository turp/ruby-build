class MsDeploy
	attr_accessor :path_to_msdeploy, :verb, :dest, :log
	attr_accessor :source, :params, :server
	attr_accessor :username, :password, :additional_parameters, :noop
	
	def initialize
		@verb = ""
		@source = Dir.pwd
		@noop = false
		yield self if block_given?
	end
	
	def sync
		@verb = "sync"
	end
	
	def whatif
		@noop = true
	end
	 
	def execute
		logger.info "Deploying '#{@source}' to '#{@dest}'" 
		if(@command.nil?)
			@command = get_msdeploy_path
		end

		cmd_params = []
		cmd_params << get_package
		cmd_params << get_destination
		cmd_params << get_parameters
		cmd_params << get_constant_parameters
		 
		if(!@additional_parameters.nil?)
			cmd_params << @additional_parameters
		end
		cmd_params << get_whatif
		cmd_params << get_log

		cmd = "#{@command} #{cmd_params.join(" ")}"
 		sh cmd do |ok, result|
			if not ok
				logger.error(cmd)
				output = File.open(log, "r").readlines.join("")
				fail "MSDEPLOY failed with status (#{result.exitstatus}):\n #{result.inspect}"
			end
		end
	end
	 
	 def get_msdeploy_path
		 #check the environment paths
		 ENV['PATH'].split(';').each do |path|
			msdeploy_path = File.join(path, 'msdeploy.exe')
			return msdeploy_path if File.exists?(msdeploy_path)
		 end

		 #check the environment variables
		 if ENV['MSDeployPath']
			msdeploy_path = File.join(ENV['MSDeployPath'], 'msdeploy.exe')
			return msdeploy_path if File.exists?(msdeploy_path)
		 end

		return windowfy('"C:/Program Files (x86)/IIS/Microsoft Web Deploy V3/msdeploy.exe"')
	 end
	
	def get_package
		#is it a direct file
		logger.info File.file?(@source)
		logger.info File.expand_path(@source)
		
		if(File.file?(@source))
			return "-source:package='#{File.expand_path(@source)}'"
		end
		
		#try directory with zip in it
		Dir.glob("#{@source}/**.zip") do |zip|
			puts File.expand_path(zip)
			return "-source:package='#{File.expand_path(zip)}'"
		end
		# must be an archive directory
		package_location = "#{@source}/archive"
		if(File.exists?(package_location))
			return "-source:archiveDir='#{File.expand_path(package_location)}'"
		end
		
		#default to content
		if(Dir.exists?(@source))
			return "-source:contentPath='#{File.expand_path(@source)}'"
		end

		raise "Could not find the MSDeploy package to deploy."
	end

	def get_destination
		if @dest.nil?
			return "-dest:auto,includeAcls='False'"
		end
	  
		destination_string = "-dest:"
		if @dest.website
			destination_string << "contentPath='#{@dest.website}'"
		else
			destination_string << "auto"
		end
		
		if @dest.server
			destination_string  << ",computerName='#{@dest.server}'"
		end
		
		if(@dest.username)
			destination_string  << ",userName='#{@username}'"
		end
	
		if(@dest.password)
			destination_string  << ",password='#{@password}'"
		end
		
		return destination_string << ",includeAcls='False'"
	end

	def get_parameters
		result = ""

		if (@params.nil?)
			return result
		end
		
		@params.each do |key, value|
			result << "-setparam:name=#{key},value='#{value}' "
		end
		return result
	 end
	 
	def get_whatif
		if(@noop)
			return "-whatif"
		end
	end

	def get_log
		if(@log)
			return " > #{@log}"
		end
	end
	
	def get_constant_parameters
		return "-verb:#{@verb} -disableLink:AppPoolExtension -disableLink:ContentExtension  -disableLink:CertificateExtension "
	end
end
