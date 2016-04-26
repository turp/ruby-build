class Make	
	def spec_flow
		options = {:web_path => nil, :test_path => nil}
		yield options if block_given?

		iis_express(options.web_path) do 
			mstest do |t|
				t.assemblies << options.test_path
			end			
		end
	end
end
