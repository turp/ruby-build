require 'logger'

# Monkey patch: 
class Logger
  def format_message(severity, datetime, progname, msg)
		msg = "#{severity} - #{msg}" unless severity == "INFO"
		#return "#{datetime.strftime("%Y-%m-%d %H:%M:%S")}: #{msg}\n"
		return "#{msg}\n"
  end
end 

def logger
	if not @logger
		@logger = Logger.new(STDOUT)
		@logger.level = logger_level
	end
	@logger
end

def logger_level
	Logger::INFO
end