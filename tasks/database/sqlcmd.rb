class SqlCmd
	attr_accessor :db

	def initialize(db = {})
		@db = db.clone
		yield self if block_given?
	end
	
	# Use sqlcmd to execute multiple statements separate with GO
	def execute_statements query, message = nil
		logger.info(message) unless message.nil?
		sh "sqlcmd -S #{db.server} -d #{db.name} #{credentials} -b -Q \"SET NOCOUNT ON;#{query}\"" do |ok, result|
			ok or fail "SQL COMMAND failed with status (#{result.exitstatus})"
		end
	end
	
	# Use sqlcmd to execute an entire file
	def execute_file(file_name, message = nil)
		logger.info(message) unless message.nil?
		logger.info("Executing #{file_name} on #{db.server}.#{db.name}")
		init_file = File.join(File.dirname(__FILE__), "scripts/init.sql")
		
		if File.exist?(file_name)
			sh "sqlcmd -S #{db.server} -d #{db.name} #{credentials} -b -i \"#{init_file}\",\"#{file_name}\"" do |ok, result|
				ok or fail "SQL COMMAND failed with status (#{result.exitstatus})"
			end
		else
			logger.info "WARNING: #{file_name} does not exist"
		end
	end
	
	def credentials   
		return db.login ? "-U #{db.login} -P #{db.password}" : "-E" 
	end
end
