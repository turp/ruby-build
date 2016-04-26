class Runner
	def run command, message = nil
		logger.info(message) unless message.nil?
		sh command
	end
end

class MockRunner
  def run command, message = nil
	logger.info message unless message.nil?
    logger.info command
  end
end