require 'erb'

class Script
	def self.get(filename, binding)
		text= IO.read(File.dirname(__FILE__)+ "/scripts/#{filename}.sql")
		template = ERB.new(text)
		return template.result(binding)
	end
end
