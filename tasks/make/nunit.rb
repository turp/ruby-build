class Make
	def nunit
		task = NUnit.new()
		yield task if block_given?		
		task.execute
	end
end

class NUnit
	attr_accessor :library, :nunit_path, :log
	
	def initialize()
		@nunit_path = "C:/Program Files/NUnit 2.4.8/bin/nunit-console.exe"
		@log = "nunit.output.xml"
	end
	
	def execute
		logger.info "Running Unit Tests"
		sh "#{nunit_path} #{log} #{library} /nologo" 
	end

	def log
		"/xml=#{@log}"
	end	
end
