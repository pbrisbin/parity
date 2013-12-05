module Parity
  class Environment
    def self.subcommand(name, &block)
      define_method(name, &block)
    end

    # TODO: restore
    subcommand(:open)    { passthrough }
    subcommand(:backup)  { heroku 'pgbackups:capture --expire' }
    subcommand(:console) { heroku 'run console' }
    subcommand(:log2viz) { open "https://log2viz.herokuapp.com/app/#{app_name}" }
    subcommand(:migrate) { heroku 'run rake db:migrate' and heroku 'restart' }
    subcommand(:tail)    { heroku 'logs --tail' }

    def initialize(environment, arguments)
      @arguments = arguments
      @app_name = Parity.config.heroku_app_name(environment)
      @remote_name = Parity.config.heroku_remote_name(environment)
    end

    def run
      command = arguments.first

      respond_to?(command) ? send(command) : passthrough
    end

    private

    attr_reader :arguments, :app_name, :remote_name

    def passthrough
      heroku arguments.join(' ').strip
    end

    def open(url)
      Kernel.system "open #{url}" # TODO: linux support
    end

    def heroku(command)
      Kernel.system "heroku #{command} --remote #{remote_name}"
    end
  end
end
