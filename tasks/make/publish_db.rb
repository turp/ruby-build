require File.join(File.dirname(__FILE__), 'msbuild.rb')

class PublishDb < MsBuild
	def initialize()
		super
		@dot_net_version = "v4.0.30319"
		@target = 'Deploy'
		
		properties['BlockOnPossibleDataLoss'] = 'false'
		properties['DropObjectsNotInSource'] = 'true'
		properties['IncludeCompositeObjects'] = 'true'
	
		yield self if block_given?
	end
	
	def server=(value)
		properties['TargetConnectionString'] = "\"Data Source=#{value};Integrated Security=True;\""
	end
	
	def database=(value)
		properties['TargetDatabaseName'] = value
	end

end
