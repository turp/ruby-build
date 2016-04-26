def sh(*cmd, &error_handler)
	options = (Hash === cmd.last) ? cmd.pop : {}
	unless block_given?
		show_command = cmd.join(" ")
		show_command = show_command[0,77] + "..."

		error_handler = lambda { |ok, status|
			ok or fail "Command failed with status (#{status.exitstatus if status}):\n [#{show_command}]"
		}
	end

	unless options[:noop]
		res = system(*cmd)
		error_handler.call(res, $?)
	end
end
