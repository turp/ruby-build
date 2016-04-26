# Monkey Patch: enhance all hash objects to allow using dot key notation: 
# h = {}
# h["my_key"] = "ABC"
# h[:abc] = "ABC"
# puts h.my_key
# puts h.abc
class Hash
  def method_missing(meth,*args)
		key = meth.id2name
    if key =~ /=$/ then
      self[key[0...-1]] = (args.length < 2 ? args[0] : args)
		else
			self[key] || self[key.to_sym]
    end
  end
	  
	def with_defaults(args = {})
		self.merge!(args) do |key, oldval, newval|
			oldval.nil? ? newval : oldval
		end
	end
end
