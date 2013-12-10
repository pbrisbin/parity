require 'delegate'
require 'ostruct'

module Parity
  class Configuration < SimpleDelegator
    LOCAL_CONFIGURATION = '.parity.yml'

    def initialize
      super(OpenStruct.new(
        heroku_app_name: "%{basename}-%{environment}",
        heroku_app_basename: File.basename(Dir.pwd),
        heroku_remote_name: "%{environment}",
        database_config_path: 'config/database.yml',
      ))

      load_local if File.exists?(LOCAL_CONFIGURATION)
    end

    def heroku_app_name(environment)
      self[:heroku_app_name] % {
        basename: heroku_app_basename,
        environment: environment
      }
    end

    def heroku_remote_name(environment)
      self[:heroku_remote_name] % { environment: environment }
    end

    private

    def load_local
      YAML.load(File.read(LOCAL_CONFIGURATION)).each do |key,value|
        send("#{key}=", value)
      end
    end
  end
end
