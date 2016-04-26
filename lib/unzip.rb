class Unzip
	attr_accessor :source, :target

	def initialize
		yield self if block_given?
	end
	
	def initialize(source, target)
		@source = source
		@target = target
	end
	
	def execute
		logger.info "Unzipping files from #{source} to #{target}"
		
		sh "#{File.dirname(__FILE__)}/7zip/7za.exe x #{source} -o#{target} -y" do |ok, result|
				ok or fail "ZIP COMMAND failed with status (#{result.exitstatus})"
		end
	end
end	
