class Make
	def grunt()
		t = Grunt.new()
		yield t if block_given?
		t.execute
	end
end

class Grunt
	
	def initialize()
	end
	
	def execute
		# verify that nodejs is installed
		sh "npm -v"
		# verify grunt is installed
		# npm config set proxy http://proxy.ch.intel.com:911
		# npm install -g grunt-cli
		# npm install grunt-contrib-concat --save-dev
		sh "grunt --version"
		
		logger.info "Running Gruntfile.js with grunt"
		cmd = "grunt"
		logger.info cmd
		sh cmd 	
	end	
end
