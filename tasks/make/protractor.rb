class Make
	def protractor_test
		options = {:web_path => nil, :protractor_conf_path => nil}
		yield options if block_given?

		iis_express(options.web_path) do 
			protractor do |t|
				t.config_file = options.protractor_conf_path
			end		
		end
	end
end

class Protractor
	attr_accessor :config_file
	
	def initialize()
	end
	
	def execute
		# verify that nodejs is installed
		sh "npm -v"
		# verify protractor is installed
		# npm config set proxy http://proxy.ch.intel.com:911
		# npm install -g protractor
		
		logger.info "Running Protractor Integration Tests"
		cmd = "protractor #{@config_file}"
		logger.info cmd
		sh cmd 	
	end	
end