require File.join(File.dirname(__FILE__), "../box/files.rb")

def ship() 
	t = Ship.new	
	yield t if block_given?
end

class Ship 	
	def msdeploy
		t = MsDeploy.new
		yield t if block_given?
		t.execute
	end
	
	def database
		t = Database.new
		yield t if block_given?
	end
	
	def web
		t = Web.new
		yield t if block_given?
	end
	
	def publish_web
		t = PublishWeb.new
		yield t if block_given?
		t.execute
	end
	
	def ssrs
		t = Files.new
		yield t if block_given?
	end
	
	def files() 
		t = Files.new
		yield t if block_given?
	end
end

class Web < Files
	def app_config
		t = AppConfig.new
		yield t if block_given?
		t.execute
	end
	
	def config_transform
		t = ConfigTransform.new
		yield t if block_given?
		t.execute
	end
end

