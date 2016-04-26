def target
	ENV['target'] = 'debug' if ENV['target'].nil?
	ENV['target'].downcase
end
