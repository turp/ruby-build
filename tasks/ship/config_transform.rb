require File.join(File.dirname(__FILE__), '../make/msbuild.rb')

class ConfigTransform < MsBuild
	attr_accessor :source_file, :transform_file, :destination_file
	
	def initialize()
		super
		@project_file = File.join(File.dirname(__FILE__), 'config_transform.msbuild.xml')
		yield self if block_given?
	end
	
	def source=(value)
		properties[:SourceFile] = value
	end
	
	def destination=(value)
		properties[:DestinationFile] = value
	end
	
	def transform=(value)
		properties[:TransformFile] = value
	end
end