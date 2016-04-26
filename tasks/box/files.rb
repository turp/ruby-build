require 'fileutils'

def files() 
	t = Files.new
	yield t if block_given?
end

class Files
	attr_accessor :target_path
	
	def initialize()
		yield self if block_given?
	end
	
	def unzip
		z = Unzip.new
		yield z if block_given?
		z.execute		
	end
	
	def copy(source = nil, destination = nil)
		if source
			copy_file(source, destination)
		else
			r = Robocopy.new
			r.to = target_path
			yield r if block_given?
			r.execute
		end
	end
	
	def copy_file(source, destination)
		FileUtils.cp source, destination
	end
	
	def permissions(file_or_folder)
		p = Permissions.new
		p.file_or_folder = File.join(target_path || "", file_or_folder)
		
		FileUtils.mkdir p.file_or_folder unless Dir.exist? p.file_or_folder
		
		yield p if block_given?
		p.execute
	end
	
	def clean(directory_name)
		if Dir.exist? directory_name
			FileUtils.rm_rf directory_name
		end
		
		Dir.mkdir directory_name
	end
	
	def combine()
		r = CombineFiles.new 	
		r.to = target_path
		yield r if block_given?
		r.execute
	end
	
	def rename(source, destination)
		FileUtils.mv source, destination
	end
	
	def exists(path)
		File.exist? path
	end
    
    def mkdir(path)
        FileUtils.mkpath(path) if not exists(path)
    end
end

class Permissions
	attr_accessor :file_or_folder
	
	def add(permission, user_or_role)
		command = "ICACLS #{windowfy(file_or_folder)} /grant #{user_or_role}:(OI)(CI)(#{permission[0]})"
		sh command
		logger.info command
	end
	
	def remove(user_or_role)
		command = "ICACLS #{windowfy(file_or_folder)} /remove[:g] #{user_or_role} /T"
		sh command
		logger.info command
	end
	
	def execute()
	end
	
end