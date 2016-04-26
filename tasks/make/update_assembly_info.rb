class Make	
	def update_assembly_info
		t = UpdateAssemblyInfo.new do |t|
			t.version = version()
		end
	
		yield t if block_given?
	
		t.execute
	end
end

class UpdateAssemblyInfo
	attr_accessor :version, :path

	def initialize()
		@path = "."
		yield self if block_given?
	end
 	
	def execute
		puts "Updating AssemblyInfo to version #{@version}"
		s = File.join(path, "**/AssemblyInfo.cs")
		Dir.glob(s) do |f|
			FileUtils.chmod 0777, f, :verbose => false
			replace_in_file(f, /AssemblyVersion\(\".*\"\)/, "AssemblyVersion(\"#{@version}\")")
			replace_in_file(f, /AssemblyFileVersion\(\".*\"\)/, "AssemblyFileVersion(\"#{@version}\")")
		end
	end
		
	def replace_in_file(filename, s, r)
		lines = []
		File.open(filename, "r"){|f| lines = f.readlines }
		File.open(filename, "w") do |f|
			lines.each do |l| 
				f << l.gsub(s, r)
			end
		end
	end
end	
