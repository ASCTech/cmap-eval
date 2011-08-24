require "src/output"
require "src/c_map"
require "src/debug"

require "rubygems"
require "nokogiri"

# Methods and classes for handling/checking the inputs to the program.
module Arguments_Helper

	def Arguments_Helper.validate_arguments args
		# Check that there are arguments.
		if args.size == 0
			Output.bad_args_exit
		end

		# Check the help flag.
		if args[0] == "-h"
			Output.help_message
			Output.exit
		end

		# Check that there is at most 1 option, and it is at the start.
		args[1..-1].each do |arg|
			if arg.start_with? "-"
				Output.bad_args_exit
			end
		end

		# Check that, if we have an option, it is valid.
		if args[0].start_with? "-"
			if !["-h", "-d", "-p", "-b"].index args[0]
				Output.bad_args_exit
			end
		end

		# Check that we have exactly enough arguments.
		if args.size != 2 and args.size != 3
			Output.bad_args_exit
		end

		# Check that we don't have that anything that is expected to be an option is an option.
		if args.size == 3 and !args[0].start_with? "-"
			Output.bad_args_exit
		end
	end

	def Arguments_Helper.get_mode args
		if args.size == 2
			return :normal_mode
		elsif args[0] == "-p"
			return :problem_statement_mode
		elsif args[0] == "-b"
			return :batch_mode
		else
			return :debug_mode
		end
	end

	def Arguments_Helper.validate_readable file_name
		if !File.readable? file_name
			Output.unreadable_file_error file_name
			Output.exit
		end
	end

	def Arguments_Helper.validate_writable file_name
		if !File.writable? file_name
			Output.unwritable_file_error file_name
			Output.exit
		end
	end

	def Arguments_Helper.get_normal_file_names args
		return args[-2], args[-1]
	end

	def Arguments_Helper.get_batch_file_names args
		return args[-2], args[-1]
	end

	def Arguments_Helper.get_problem_statement_names args
		return args[-2], args[-1]
	end

	def Arguments_Helper.write_text_to_text_file file_name, text
		# Create the directory, if it doesn't already exist.

		if file_name.include? "\\" or file_name.include? "/"
			directory_part = file_name[/.*(?=[\/\\][^\/\\]*)/]

			if !File.exist? directory_part
				Dir.mkdir directory_part
			end
		end

		File.open file_name, "w" do |file|
			file.print text
		end
	end
end
