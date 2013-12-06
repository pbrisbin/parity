require 'parity/backup'
require 'parity/configuration'
require 'parity/environment'
require 'parity/usage'

module Parity
  class << self
    def run(environment, arguments)
      Environment.new(environment).run(arguments)
    rescue => ex
      print_error(ex, ex.is_a?(ArgumentError))
      exit 1
    end

    def configure
      yield config if block_given?
    end

    def config
      @config ||= Configuration.new
    end

    private

    def print_error(ex, show_usage = false)
      $stderr.puts "Error: (#{ex.class}) #{ex.message}"
      $stderr.puts Usage.new if show_usage
    end
  end
end
