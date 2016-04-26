def database()
	db = Database.new
	yield db if block_given?
end

class Database
	attr_accessor :server, :name, :login, :password, :source_path, :schema, :owner
	
	def publish 
		t = PublishDb.new
		yield t if block_given?
		t.execute
	end
	
	def sql
		ado = Ado.new(self)
		yield ado if block_given?
	end
	
	def create_db_if_it_does_not_exist
		logger.info "Creating database #{name} (if it doesn't already exist)"
		Ado.new(self) do |ado|
			ado.db.name = 'master'
			ado.execute_non_query "IF NOT EXISTS (select * from sys.databases where name = '#{name}') CREATE DATABASE #{name}"
		end
		SchemaVersion.new(self, schema).create_schema_table_if_it_does_not_exist()
	end
	
	def drop_db_if_exists_then_create_db
		drop_db
		create_db_if_it_does_not_exist
	end

	def change_db_owner
		logger.info "Changing database owner to #{owner}"
		Ado.new(self) do |ado|
			ado.execute_non_query "EXEC dbo.sp_changedbowner @loginame = '#{owner}'"
		end
	end
	
	def create_schema_if_does_not_exist
		Ado.new(self) do |ado|
			ado.execute_non_query "IF NOT EXISTS (SELECT schema_name FROM information_schema.schemata WHERE schema_name ='#{schema}') BEGIN EXECUTE ('CREATE SCHEMA [#{schema}]') 	INSERT INTO SchemaVersion (Version, Script, SchemaName, ScriptRunDate) VALUES(0, 'N/A', '#{schema}', GETDATE()) END"			
		end
	end
    
	def cleanup_deprecated_objects
		execute_template "cleanup_up_deprecated_objects", "Cleaning up old objects no longer in source code control"
	end
	
	def drop_users_from_database
		execute_template "drop_users", "Dropping users from #{name}"
	end
	
	def drop_db
		logger.info "Dropping database #{name}"
		Ado.new(self) do |ado|
			ado.db.name = 'master'
			ado.execute_non_query "IF EXISTS (select * from sys.databases where name = '#{name}') ALTER DATABASE #{name} SET SINGLE_USER WITH ROLLBACK IMMEDIATE"
			ado.execute_non_query "IF EXISTS (select * from sys.databases where name = '#{name}') DROP DATABASE #{name}"
        end
    end
    
	def create_login
		task = CreateLogin.new(self)
		yield task if block_given?
		task.execute		
	end
	
	def restore
		task = DbRestore.new(self)
		yield task if block_given?
		task.execute
	end

	def backup
		task = DbBackup.new(self)
		yield task if block_given?
		task.execute
	end
	
	def migrate
		task = DbMigrate.new(self)
		yield task if block_given?		
		task.execute
	end
	
	def execute_script file_name
		SqlCmd.new(self) do |sql|
			sql.execute_file(file_name)
		end
	end
	
	def linked_server()
		task = LinkedServer.new(self)
		yield task if block_given?
		task.execute	
	end

	def set_recovery_mode(mode = 'SIMPLE')
		if ['FULL', 'SIMPLE'].include? mode.upcase		
			logger.info "SETTING RECOVERY MODE TO '#{mode}'"
			Ado.new(self) do |ado|
				ado.db.name = 'master'
				ado.execute_non_query "ALTER DATABASE [#{name}] SET RECOVERY #{mode} WITH NO_WAIT"
			end
		else
			raise "Recovery mode can only be set to FULL or SIMPLE(default)" 
		end
	end
	
	def execute_template(filename, message)
		SqlCmd.new(self) do |cmd|
			cmd.execute_statements parse_template(filename), message
		end	
	end
	
	def parse_template(filename)
		Script.get(filename, binding)
	end
end
