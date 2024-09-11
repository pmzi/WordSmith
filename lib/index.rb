# typed: true

require_relative 'command_runner/index'

module WordSmith
  extend T::Sig

  sig { params(args: T::Array[String]).void }
  def self.run(args)
    CommandRunner.run(args)
  rescue CommandRunner::ArgumentError => e
    puts e.message

    exit 1
  end
end

WordSmith.run(ARGV)
