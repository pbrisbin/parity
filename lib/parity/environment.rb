module Parity
  class Environment
    def initialize(environment, arguments)
      @environment = environment
      @arguments = arguments
      @app_name = Parity.config.heroku_app_name(environment)
      @remote_name = Parity.config.heroku_remote_name(environment)
    end

    def run
      command, *args = arguments

      public_send(command, *args)

    rescue NoMethodError
      passthrough
    end

    def backup
      heroku 'pgbackups:capture --expire'
    end

    def console
      heroku 'run console'
    end

    def migrate
      heroku 'run rake db:migrate' and heroku 'restart'
    end

    def tail
      heroku 'logs --tail'
    end

    def log2viz
      browse "https://log2viz.herokuapp.com/app/#{app_name}"
    end

    def restore(from)
      Backup.new(from: from, to: environment).restore
    end

    private

    attr_reader :environment, :arguments, :app_name, :remote_name

    def passthrough
      heroku arguments.join(' ').strip
    end

    def heroku(command)
      Kernel.system "heroku #{command} --remote #{remote_name}"
    end

    def browse(url)
      browser = ENV['BROWSER'] || 'open'

      Kernel.system "#{browser} #{url}"
    end
  end
end
