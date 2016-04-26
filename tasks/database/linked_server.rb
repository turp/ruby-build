class LinkedServer
	attr_accessor :db, :sql, :name, :db_server, :db_name, :login_name, :password, :provider, :debug, :connection_timeout, :query_timeout
		
	def initialize(db)
		@provider = 'SQLOLEDB'
		@db = db
        @debug = false
		@connection_timeout = 0
		@query_timeout = 0
	end
	
	def execute()
		execute_template "linked_server", "Creating linked server #{name}"
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
