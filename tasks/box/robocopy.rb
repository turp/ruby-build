class Robocopy
  attr_accessor :from, :to, :exclude, :include, :verbose, :include_empty_directories, :clean_destination

  def initialize(runner = RobocopyRunner.new)
    @include = { :files => ["*.*"]}
    @exclude = { :files => [], :directories => []}
	@verbose = false
	@include_empty_directories = true
	@clean_destination = true
    @runner = runner
  end
  
  def to=(value)
	@to.nil? ? @to = value : @to = File.join(@to, value)	
  end
  
  def execute()
    raise "No files or directories were specified" if @include.files.length == 0 and @include.directories.length == 0
    raise "Destination folder was not specified" if @to.nil?

	@include.files.each do |f|
		src_path = "#{File.expand_path(from)}"
		if (!Dir.exists?(src_path))
			logger.warn "Directory #{src_path} DOES NOT EXIST"
		else
			cmd = "robocopy \"#{src_path}\" \"#{to}\" #{File.basename(f)} #{cleanup_destination} #{copy_empty_directories} /MT #{exclusions} #{verbosity}"
			msg = "COPYING #{File.basename(f)} from '#{src_path}' to '#{to}'"
			@runner.run(cmd, msg)
		end
	end
  end
  
  def copy_empty_directories
	return @include_empty_directories ? "/E" : "/S"
  end
  
  def verbosity
	return @verbose ? "/V" : "/NFL /NDL /NC /NS /NJH /NP /NJS"
  end
  
  def exclusions
	return "" if @exclude.files.size == 0 && @exclude.directories.size == 0 
	"/XF " + @exclude.files.join(" ") + " /XD " + @exclude.directories.join(" ")
  end
  
  def cleanup_destination
	return @clean_destination ? "/PURGE" : ""
  end
end

class RobocopyRunner
    FAIL = "Some files or directories could not be copied (copy errors occurred and the retry limit was exceeded)."
	MISMATCHES = "Some Mismatched files or directories were detected. Examine the output log. Some housekeeping may be needed."
	XTRA = "Some Extra files or directories were detected. Examine the output log for details." 
	OKCOPY = "One or more files were copied successfully (that is, new files have arrived)"

	def initialize
		@errors = {
			16 => "Serious error. Robocopy did not copy any files. Either a usage error or an error due to insufficient access privileges on the source or destination directories.", 
			15 => "#{OKCOPY} #{FAIL} #{MISMATCHES} #{XTRA}",
			14 => "#{FAIL} #{MISMATCHES} #{XTRA}",
			13 => "#{OKCOPY} #{FAIL} #{MISMATCHES}",
			12 => "#{FAIL} #{MISMATCHES}",
			11 => "#{OKCOPY} #{FAIL} #{XTRA}",
			10 => "#{FAIL} #{XTRA}",
			9 => "#{OKCOPY} #{FAIL}",
			8 => "#{FAIL}",
			7 => "#{OKCOPY} #{MISMATCHES} #{XTRA}",
			6 => "#{MISMATCHES} #{XTRA}",
			5 => "#{OKCOPY} #{MISMATCHES}",
			4 => "#{MISMATCHES}",
			#3 => "#{OKCOPY} #{XTRA}",
			#2 => "#{XTRA}"
		}	
	end
	
	def run(command, message = nil)
		logger.info(message) unless message.nil?
		
		error_handler = lambda { |ok, status|
			if @errors.include?(status.exitstatus) 
				logger.info command
				fail "ROBOCOPY FAILED: Exit Status: #{status.exitstatus} - #{@errors[status.exitstatus]})"
			end
		}

		result = system command
		error_handler.call(result, $?)	
  end
end
