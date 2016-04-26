
class SchemaVersion
	attr_accessor :db, :schema
	
	def initialize(db, schema)
		@db = db.clone
		@schema = schema
		yield self if block_given?
		create_schema_table_if_it_does_not_exist()
	end

	def get()
		version = 0
		Ado.new(db) do |ado|
			version = ado.execute_scalar("SELECT TOP 1 Version FROM SchemaVersion WHERE SchemaName = '#{schema}' ORDER BY Version DESC")
			version = 0 if version.nil?
			logger.info("Schema version: #{version} in #{schema}")
		end

		return version
	end
	
	def update(migration_script)
		Ado.new(db) do |ado|
			ado.execute_non_query("INSERT INTO SchemaVersion (Version, Script, SchemaName, ScriptRunDate) VALUES(#{migration_script.version}, '#{migration_script.filename}', '#{schema}', GETDATE())") 	
		end
	end
	
	def create_schema_table_if_it_does_not_exist()
		SqlCmd.new(db) do |sql|
			sql.execute_statements(Script.get("create_schema_version_table", binding)) 
		end
	end
end

class DbMigrate
	attr_accessor :db, :path, :schema
	
	def initialize(db)
		@db = db.clone
		@schema = schema.nil? ? 'dbo' : schema
		@path = 'Database/migrations'
		yield self if block_given?
	end

	def execute
		version = SchemaVersion.new(db, schema).get
		logger.info "Migrating database from version #{version} in #{schema} schema"
		
		get_scripts_greater_than(version).each do |script|
			SqlCmd.new(db).execute_file(script.filename, "Executing #{script.filename}")
			SchemaVersion.new(db, schema).update(script)
		end
	end
	
	def get_scripts_greater_than(version)
		list = []
		Dir.glob("#{path}/*.SQL") do |filename|
			f = MigrationScript.new(filename)
			list << f if f.version > version
		end
		return list
	end
end

class MigrationScript
	attr_accessor :version, :filename

	def initialize(filename)
		@version = File.basename(filename).split("_")[0].to_i
		@filename = filename
	end
end
