# typed: true

require_relative 'command_runner/index'
require_relative 'services/logger'
require_relative 'migrations/index'
require_relative 'helpers/logo_visualizer'
module WordSmith
  class << self
    extend T::Sig

    sig { params(args: T::Array[String]).void }
    def run(args)
      Helpers::LogoVisualizer.draw

      run_migrations

      CommandRunner.run(args)
    rescue CommandRunner::ArgumentError => e
      puts e.message

      exit 1
    end

    private

    def run_migrations
      Services::Logger.debug_log('Running migrations...')

      Migrations.run

      Services::Logger.debug_log('Migrations complete.')
    end
  end
end
