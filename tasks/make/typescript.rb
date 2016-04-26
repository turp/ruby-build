class Make
	def typescript
		t = TypeScript.new

		yield t if block_given?

		t.execute
	end
end

class TypeScript
	attr_accessor :path, :version, :compiler, :ecmascript_version
	
	def initialize()
		@version = "1.0.0"
		@path = "."
		@ecmascript_version = 5
		@file_count = 0
	end
 	
	def execute
		@compiler = File.join(File.dirname(__FILE__), "/TypeScript/#{@version}/tsc.exe --target ES#{@ecmascript_version}")
		logger.info "Compiling Typescript files"
		logger.info "Using compiler #{compiler}"

		start_time = Time.now
		file_name = "tsc_filelist.txt"
				
		create file_name

		tsc "@" + file_name

		delete file_name
		
		logger.info "Compiled #{@file_count} Typescript files in #{Time.now - start_time} seconds"	
	end

	def tsc(filename)
		logger.info "Compiling Typescript files in '#{path}'"
		sh "#{compiler} --removeComments #{filename}"
	end
		
	def delete(file_name)
		File.delete(file_name) if File.exist?(file_name)
	end
	
	def create(file_name)
		File.open(file_name, "w") do |f|
			s = File.join(path, "**/*.ts")
			Dir.glob(s) do |tsfile|
				f << tsfile + "\n"
				@file_count = @file_count + 1
			end
		end
	end
end	
