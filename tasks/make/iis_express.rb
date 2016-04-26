require 'fileutils'
include FileUtils

class Make
	def iis_express(web_path)
		begin
			iis = IisExpress.new()
			iis.path = File.absolute_path(web_path)
			iis.start()
			
			yield iis if block_given?		

			iis.stop()
		rescue Exception => e
			logger.info "Killing IIS Express due to error..."
			iis.stop()
			raise e  
		end
	end
end

class IisExpress
	attr_accessor :config_file, :path
	
	def initialize()
		@config_file = File.absolute_path(File.join(File.dirname(__FILE__), "iis_express.config"))
		yield self if block_given?
	end

	def path
		return '.' if @path.nil?
		windowfy(@path).gsub('\\') { '\\\\' }
	end

	def config_file
		windowfy(@config_file)
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
	
	def start
		cmd = 'start C:\"Program Files (x86)"\"IIS Express"\iisexpress.exe /config:"' + config_file + '"'
		replace_in_file(config_file, /physicalPath=\".*\"/, "physicalPath=\"#{path}\"")

		logger.info "Starting IIS Express"
		sh cmd
	end
	
	def stop
		begin
			logger.info "Stopping IIS Express"
			sh "taskkill /IM IISExpress.exe /F"
			sh "taskkill /IM chromedriver.exe /F"
		rescue Exception => e
		end
	end
end
