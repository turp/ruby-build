require File.join(File.dirname(__FILE__), "files.rb")

def box() 
	t = Box.new
	yield t if block_given?
end

class Box < Files

end