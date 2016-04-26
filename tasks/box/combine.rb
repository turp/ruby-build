class CombineFiles
   attr_accessor :to, :from, :include, :exclude
    
	def initialize
		@include = { :files => [], :directories => []}
		yield self if block_given?
		@include.directories << "." if @include.directories.empty? 
		@include.files << "*.*" if @include.files.empty? 
	end
	
	def to=(value)
		if @to.nil? 
			@to = value 
		else
			@to = File.join(@to, value)
		end
	end
  
	def file_list
		list = []
	
		@include.directories.each do |dir_name|
			@include.files.each do |file_name|
				Dir.glob(File.join(@from, dir_name, file_name)) do |filename|
					list << filename
				end
			end
		end
		return list
	end
	
	def execute
		raise "No files or directories were specified" if @include.files.length == 0 and @include.directories.length == 0
		raise "Destination file was not specified" if @to.nil?

		logger.info "Combining files into '#{to}'"
		rm_f to, :verbose => false
		mkpath File.dirname(to)
		
		list = file_list.collect{ |f| "TYPE \"#{windowfy(f)}\" >> #{windowfy(to)}&" }
		cmd = ''
		list.each do |list_cmd|
			cmd = cmd + list_cmd
			if cmd.length > 5000
				sh cmd, :verbose => false
				cmd = ''
			end
		end
		sh cmd, :verbose => false unless cmd.length == 0
	end
		
	def usage
			<<EOS
CombineFiles.new() do |p|
	p.to = 'db/Benzene/Db.App.Script.sql'
	p.from = [
		'db/Benzene/Views/*.sql', 'db/Benzene/Functions/*.sql',
		'db/Benzene/Triggers/*.sql', 'db/Benzene/Procedures/*.sql'
	]
end
EOS
	end
end

