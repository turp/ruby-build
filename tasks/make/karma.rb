class Make
	def karma()
		t = Karma.new()
		yield t if block_given?
		t.execute
	end
end

class Karma
	attr_accessor :config_file
	
	def initialize()
	end
	
	def execute
		# verify that nodejs is installed
		sh "npm -v"
		# verify karma is installed
		# npm config set proxy http://proxy.ch.intel.com:911
		# npm install -g karma
		sh "karma --version"
		
		logger.info "Running Jasmine Tests Using Karma"
		cmd = "karma start #{@config_file}"
		logger.info cmd
		sh cmd 	
	end	
end
