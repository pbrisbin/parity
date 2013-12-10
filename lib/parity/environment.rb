module Parity
  class Environment
    def initialize(environment, subcommands)
      self.environment = environment
      self.subcommand = subcommands[0]
      self.arguments = subcommands[1..-1]
    end

    def run
      if self.class.private_method_defined?(subcommand)
        send(subcommand)
      else
        run_via_cli
      end
    end

    private

    attr_accessor :environment, :subcommand, :arguments

    def open
      run_via_cli
    end

    def run_via_cli
      Kernel.system "heroku #{pass_through} --remote #{heroku_remote_name}"
    end

    def backup
      Kernel.system "heroku pgbackups:capture --expire --remote #{heroku_remote_name}"
    end

    def console
      Kernel.system "heroku run console --remote #{heroku_remote_name}"
    end

    def log2viz
      Kernel.system "open https://log2viz.herokuapp.com/app/#{heroku_app_name}"
    end

    def migrate
      Kernel.system %{
        heroku run rake db:migrate --remote #{heroku_remote_name} &&
        heroku restart --remote #{heroku_remote_name}
      }
    end

    def tail
      Kernel.system "heroku logs --tail --remote #{heroku_remote_name}"
    end

    def heroku_app_name
      Parity.config.heroku_app_name(environment)
    end

    def heroku_remote_name
      Parity.config.heroku_remote_name(environment)
    end

    def pass_through
      [subcommand, arguments].join(' ').strip
    end
  end
end
