require "System.Data"

class Ado
	include System::Data
	include System::Data::SqlClient
	
	attr_accessor :db
	
	def initialize(my_database = {})
		@db = my_database.clone
		yield self if block_given?
	end
	
	def execute_non_query(sql, message = nil)
		logger.info(message) unless message.nil?
		ado_connection do |connection|
			command = SqlCommand.new(sql, connection)
			command.command_type = CommandType.text
			#logger.info(sql)
			command.execute_non_query
		end
	end

	def execute_scalar(sql, message = nil)
		logger.info(message) unless message.nil?
		ado_connection do |connection|
			command = SqlCommand.new(sql, connection)
			command.command_type = CommandType.text
			return command.execute_scalar
		end
	end
	
	def execute_dataset(sql)
		ado_connection do |connection|
			command = SqlCommand.new(sql, connection)
			command.command_type = CommandType.text

			adapter = SqlDataAdapter.new(command)
			dataset = DataSet.new
			adapter.fill(dataset)
			
			return dataset
		end
	end

	def ado_connection
		#logger.info("Opening connection #{connection_string}")
		c = SqlConnection.new(connection_string)
		c.open
		
		yield c if block_given?
		
		c.close unless c.nil?
	end

	def connection_string
		s = @db.login ? "User Id=#{@db.login};Password=#{@db.password};" : "Integrated Security=True;"
		return s + "Data Source=#{@db.server}; Initial Catalog=#{@db.name};"
	end
end
