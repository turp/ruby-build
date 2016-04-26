def windowfy(path)
	return "" if path.nil?
	path.gsub(/\//, "\\")
end
