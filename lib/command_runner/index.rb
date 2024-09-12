# typed: true
# frozen_string_literal: true

require 'optparse'
require_relative '../../version'
require_relative '../services/open_a_i'
require_relative '../helpers/str'
require_relative 'translation'
require 'sorbet-runtime'

module WordSmith
  module CommandRunner
    class ArgumentError < StandardError; end

    class << self
      extend T::Sig

      EXECUTABLE_NAME = 'ws'
      OPENAI_API_KEY_COMMAND = '--set-openai-api-key'
      OPENAI_ORG_ID_COMMAND = '--set-openai-org-id'

      sig { params(args: T::Array[String]).void }
      def run(args)
        args_clone = args.clone
        options = T.let({ no_cache: false }, { no_cache: T::Boolean })

        parser = OptionParser.new do |opts|
          opts.banner = "Usage: #{EXECUTABLE_NAME} [word] [options...]"

          opts.on("#{OPENAI_API_KEY_COMMAND} [key]", 'Set the OpenAI API key') do |key|
            store_open_a_i_api_key(key)

            exit
          end

          opts.on("#{OPENAI_ORG_ID_COMMAND} [key]", 'Set the OpenAI Org ID') do |key|
            store_open_a_i_org_id(key)

            exit
          end

          opts.on('--no-cache', 'Translate word without using cache') do
            options[:no_cache] = true
          end

          opts.on_tail('-h', '--help', 'Show help') do
            print_help(opts)

            exit
          end

          opts.on_tail('-v', '--version', 'Show version') do
            print_version

            exit
          end
        end

        parser.parse!(args_clone)

        word = args_clone.first&.chomp

        raise ArgumentError, 'No word provided' if word.nil? || word.empty?

        Translation.run(word, options)
      end

      private

      sig { params(opts: OptionParser).void }
      def print_help(opts)
        Kernel.puts opts

        return unless WordSmith::Services::OpenAI.api_key.nil?

        open_a_i_message = T.let("
                To use OpenAI, you need to set an API key and Org ID.
                You can set the API key using '#{EXECUTABLE_NAME} #{OPENAI_API_KEY_COMMAND} <key>'
                You can set the Org ID using '#{EXECUTABLE_NAME} #{OPENAI_ORG_ID_COMMAND} <key>'
              ", String)
        Kernel.puts WordSmith::Helpers::Str.lstr_every_line(open_a_i_message)
      end

      sig { void }
      def print_version
        puts "Version #{WordSmith::VERSION}"
      end

      sig { params(key: String).void }
      def store_open_a_i_api_key(key)
        WordSmith::Services::OpenAI.store_api_key(key)

        puts 'OpenAI API key set!'
      end

      sig { params(key: String).void }
      def store_open_a_i_org_id(key)
        WordSmith::Services::OpenAI.store_org_id(key)

        puts 'OpenAI Org ID set!'
      end
    end
  end
end
