require 'rubygems'
require 'pp'

require 'fileutils'
include FileUtils

Dir.glob(File.join(File.dirname(__FILE__), "lib/**/*.rb")) do |f|	
	require f
end

Dir.glob(File.join(File.dirname(__FILE__), "tasks/**/*.rb")) do |f|	
	require f
end

def welcome(app_name = "Unknown App")
	logger.info "Building #{app_name} Version: #{version}"
	logger.info "Build Time #{Time.now} WW: #{Time.now.ww}"
end

