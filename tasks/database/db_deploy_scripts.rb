class DbDeployScripts
	attr_accessor :db, :path, :output_path
	
	def initialize(db)
		@db = db.clone
		yield self if block_given?
	end
	
	def execute()
		raise "Script path #{path} is not valid" if not Dir.exist? path

		output_file = "#{output_path || path}/Db.App.Script.sql"
		
		SqlCmd.new(db) do |sql|
			sql.execute_file(output_file)
		end
	end		
end
