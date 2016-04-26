class Make
	def nuget()
		t = new Nuget()
		yield t if block_given?
	end
end

class Nuget
	attr_accessor :server, :apikey
	
	def initialize()
		@server = "http://novi.intel.com"
		@apikey = "HBYzt0Bq6kaoww/3tffb7Q=="
	end
 	
	def pack()
		t = { :specfile => '', :output => '', :version => version() }
		yield t if block_given?
		logger.info "Packing file #{t.specfile}"
		execute("pack #{t.specfile} -OutputDirectory #{t.output} -Version #{t.version}")
	end
	
	def push()
		t = { :server => @server, :apikey => @apikey, :package => '' }
		yield t if block_given?
		logger.info "Pushing file #{t.specfile}"
		execute("push #{t.package} #{t.apikey} -s #{t.server}")
	end
		
	def delete()
		t = { :server => @server, :apikey => @apikey, :package => '', :version => '' }
		yield t if block_given?	
		execute("delete #{t.package} #{t.version} #{t.apikey} -s #{t.server}")
	end	
	
	def execute(cmd)
		path = Dir.glob("**/.nuget/nuget.exe")[0]
		logger.info "#{path} #{cmd}"
		sh "#{path} #{cmd}"
	end
end	
