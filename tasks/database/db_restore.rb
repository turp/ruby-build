class DbRestore
	attr_accessor :backup_file, :restore_path, :logical_files, :db, :recovery_mode, :verbose
		
	def initialize(db)
		@db = db
		@logical_files = {}
		@recovery_mode = 'simple'
		@verbose = false
	end
	
	def execute()
		restore_db
		fix_user_ids
		shrink_db
		set_recovery_mode
	end
	
	def set_recovery_mode
		db.set_recovery_mode(@recovery_mode) if @recovery_mode
	end
	
	def move(files = {})
		files.each do |k, v|
			if @restore_path
				@logical_files[k] = "#{windowfy(File.join(restore_path, v))}"
			else
				@logical_files[k] = "#{windowfy(v)}"
			end
		end
	end
	
	def logical_files
		@logical_files
	end
		
	def restore_path				
		windowfy(File.expand_path(@restore_path)) if @restore_path
	end
		
	def backup_file					
		windowfy(@backup_file)
	end

	def backup_file=(file_name)
		if file_name =~ /\.zip$/
			Unzip.new(file_name, File.dirname(file_name)).execute
		end
		@backup_file = get_backup_file_name(file_name)	
	end
	
	def get_backup_file_name(filename)
		filename = filename.sub /\.zip/, ".bak"
		filename = File.expand_path(filename) unless filename =~ /\/\/./
		filename
	end
		
	def restore_db
		execute_template "restore_db", "Restoring database '#{db.name}' on server '#{db.server}' from '#{backup_file}'"
	end
	
	def fix_user_ids
		execute_template "fix_user_id", "Fixing SQL Server login and user_ids"
	end
	
	def shrink_db
		execute_template "shrink_db", "Shrinking database"
	end

	def execute_template(filename, message)
		sql = parse_template(filename)
		logger.info(sql) if @verbose
		SqlCmd.new(db) do |cmd|
			cmd.execute_statements sql, message
		end	
	end
	
	def parse_template(filename)
		Script.get(filename, binding)
	end
end
