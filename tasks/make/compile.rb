require File.join(File.dirname(__FILE__), 'msbuild.rb')

class Make
	def compile
		t = Compile.new do |t|
			t.config = "release"
			t.dot_net_version = "v4.0.30319"
		end
	
		yield t if block_given?

		t.execute
	end
end

class Compile < MsBuild
	def initialize()
		super
		@target = 'Rebuild'
		yield self if block_given?
	end
	
	def solution=(value)
		@project_file = value
	end
	
	def solution
		@project_file
	end
end
