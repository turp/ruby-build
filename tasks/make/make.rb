def make()
	m = Make.new
	yield m if block_given?
end

class Make	
	def update_nuget_packages
		logger.info "Updating NuGet Packages"
		nuget = Dir.glob("**/.nuget/nuget.exe")[0]
		
		args = {"app_path" => nuget, "package_path" => "packages" }
		
		yield args if block_given?
		
		s = File.join(".", "**/packages.config")
		Dir.glob(s) do |f|
			logger.info "Updating packages in '#{f}'"
			
			cmd = args.app_path + " install #{f} -RequireConsent -o " + args.package_path
			
			sh cmd do |ok, result|
				if not ok
					logger.error(cmd)
					fail "NUGET UPDATE failed with status (#{result.exitstatus}):\n #{result.inspect}"
				end
			end
		end
	end
end
