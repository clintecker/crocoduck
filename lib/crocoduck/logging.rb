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
        logger.send(level, '%s (%.1fs)' % [ message, ms ])
        result
      end
  end
end
