# Copyright, 2017, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
require 'logger'

require_relative 'command/serve'
require_relative 'command/virtual'

require_relative 'version'

require 'samovar'

module Falcon
	module Command
		def self.parse(*args)
			Top.parse(*args)
		end
		
		class Top < Samovar::Command
			self.description = "An asynchronous HTTP client/server toolset."
			
			options do
				option '--verbose | --quiet', "Verbosity of output for debugging.", key: :logging
				option '-h/--help', "Print out help information."
				option '-v/--version', "Print out the application version."
			end
			
			nested '<command>', {
				'serve' => Serve,
				'virtual' => Virtual
			}, default: 'serve'
			
			def verbose?
				@options[:logging] == :verbose
			end
			
			def quiet?
				@options[:logging] == :quiet
			end
			
			def invoke(program_name: File.basename($0))
				if verbose?
					Async.logger.level = Logger::DEBUG
				elsif quiet?
					Async.logger.level = Logger::WARN
				else
					Async.logger.level = Logger::INFO
				end
				
				if @options[:version]
					puts "falcon v#{Falcon::VERSION}"
				elsif @options[:help] or @command.nil?
					print_usage(program_name)
				else
					@command.invoke(self)
				end
			end
		end
	end
end
