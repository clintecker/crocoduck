# Include Loggging into your class to get a logger and benchmark
# object for logging errors or information to stdout and for profiling
# interesting bits of code.
require 'benchmark'
require 'logger'

module Crocoduck
  def self.logger
    @logger ||= Logger.new($stderr)
  end

  module Logging
    private
      def logger
        Crocoduck.logger
      end

      def benchmark(level, message)
        result = nil
        ms = Benchmark.realtime { result = yield }
        logger.send(level, '%s (%.5fs)' % [ message, ms ])
        result
      end
  end
end
