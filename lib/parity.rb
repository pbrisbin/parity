require 'parity/configuration'
require 'parity/development'
require 'parity/staging'
require 'parity/production'
require 'parity/usage'

module Parity
  class << self
    def config
      @config ||= Configuration.new
    end

    def configure
      yield config if block_given?
    end
  end
end
