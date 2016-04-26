require File.join(File.dirname(__FILE__), 'msbuild.rb')

class PublishWeb < MsBuild
	def initialize()
		super
		@dot_net_version = "v4.0.30319"
		properties['DeployOnBuild'] = 'true'
	
		yield self if block_given?
	end
	
	def profile=(value)
		properties['PublishProfile'] = value
	end
	
	def profile
		properties['PublishProfile']
	end
end
