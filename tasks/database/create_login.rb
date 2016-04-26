class CreateLogin
	attr_accessor :name, :password, :default_database, :db
		
	def initialize(db)
		@provider = 'SQLOLEDB'
		@default_database = 'master'
		@db = db
	end
	
	def execute()
		execute_template "create_login", "Creating login #{name}"
	end

	def execute_template(filename, message)
		SqlCmd.new(db) do |sql|
			sql.execute_statements parse_template(filename), message
		end
	end
	
	def parse_template(filename)
        script = Script.get(filename, binding)
        File.open(@name + '.sql', 'w') {|f| f.write(script) } if @debug
        script
	end
end
