module Parity
  class Environment
    def self.subcommand(name, &block)
      define_method(name, &block)
    end

    subcommand(:backup)  { heroku 'pgbackups:capture --expire' }
    subcommand(:console) { heroku 'run console' }
    subcommand(:log2viz) { open "https://log2viz.herokuapp.com/app/#{app_name}" }
    subcommand(:migrate) { heroku 'run rake db:migrate' and heroku 'restart' }
    subcommand(:open)    { passthrough }
    subcommand(:restore) { |from| Backup.new(from: from, to: environment).restore }
    subcommand(:tail)    { heroku 'logs --tail' }

    def initialize(environment, arguments)
      invalid_usage! if arguments.empty?

      @environment = environment
      @arguments = arguments
      @app_name = Parity.config.heroku_app_name(environment)
      @remote_name = Parity.config.heroku_remote_name(environment)
    end

    def run
      command, *args = arguments

      respond_to?(command) ? send(command, *args) : passthrough
    end

    private

    attr_reader :environment, :arguments, :app_name, :remote_name

    def invalid_usage!
      puts Usage.new and exit 1
    end

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
