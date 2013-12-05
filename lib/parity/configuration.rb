module Parity
  class Configuration
    attr_accessor :database_config_path, :heroku_app_basename

    def initialize
      @database_config_path = 'config/database.yml'
    end

    def heroku_app_name(environment)
      basename = heroku_app_basename || File.basename(Dir.pwd)

      [basename, environment].join('-') # TODO: configuration overrides
    end

    def heroku_remote_name(environment)
      environment # TODO: configuration overrides
    end
  end

  class << self
    attr_accessor :config
  end

  def self.configure
    self.config ||= Configuration.new

    if block_given?
      yield config
    end
  end
end
