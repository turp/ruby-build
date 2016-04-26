class DbBackup
	attr_accessor :path, :db, :compress
		
	def initialize(db)
		@db = db
		@compress = true
		yield self if block_given?
	end
	
	def execute()
		execute_template "db_backup", "Backing up database #{db.name} to #{path}"
	end
		
	def path				
		filename = db.name + ".bak"
		# no path - send back filename
		return windowfy(filename) if @path.nil?
		# path is directory - send back path + filename
		return windowfy(File.join(@path, filename)) if Dir.exists?(@path)
		# path is a filename
		return windowfy(@path)
	end
			
	def execute_template(filename, message)
		SqlCmd.new(db) do |cmd|
			cmd.execute_statements parse_template(filename), message
		end	
	end
	
	def parse_template(filename)
		Script.get(filename, binding)
	end
end
