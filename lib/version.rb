def version
	ENV['CCNETLABEL'] || "#{yyyy_mm_dd}.#{next_build_number}"
end

def yyyy_mm_dd
	major = Time.now.year
	minor = Time.now.month
	tiny  = Time.now.day

	return [major, minor, tiny].join('.')
end

def next_build_number
	if @last_build_number.nil?
		@last_build_number = sprintf("%02d%02d", Time.now.hour, Time.now.min)
	end
	@last_build_number
end
