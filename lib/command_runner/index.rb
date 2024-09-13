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
    class BadPermutationOfArgumentsError < ArgumentError; end

    class << self
      extend T::Sig

      EXECUTABLE_NAME = 'ws'
      OPENAI_API_KEY_COMMAND = '--set-openai-api-key'
      OPENAI_ORG_ID_COMMAND = '--set-openai-org-id'

      class Options < T::Struct
        prop :no_cache, T::Boolean
        prop :file_path, T.nilable(String)
      end

      sig { params(args: T::Array[String]).void }
      def run(args)
        args_clone = args.clone
        options = Options.new(no_cache: false, file_path: nil)

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
            options.no_cache = true
          end

          opts.on('-f', '--file [FILE_PATH]', 'Read words from a file') do |file_path|
            options.file_path = file_path
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

        input_text = args_clone.join(' ').chomp

        if !input_text.empty? && !options.file_path.nil?
          raise BadPermutationOfArgumentsError, 'Both word and file path cannot be provided'
        end

        raise ArgumentError, 'No word or file path provided' if input_text.empty? && options.file_path.nil?

        translation_options = {
          no_cache: options.no_cache
        }

        unless options.file_path.nil?
          raise ArgumentError, "File not found: #{options.file_path}" unless File.exist?(options.file_path)

          File.readlines(T.must(options.file_path)).each_with_index do |line, index|
            puts Rainbow('-' * 60).yellow.bright unless index.zero?

            Translation.run(line, translation_options)
          end

          return
        end

        Translation.run(input_text, translation_options)
      end

      private

      sig { params(opts: OptionParser).void }
      def print_help(opts)
        puts Helpers::Str.lstr_every_line("
          Translate words, phrases and words in context of a sentence.

          -> To translate a word or a phrase, just run:
            #{Rainbow(EXECUTABLE_NAME + ' [word/phrase]').blue.bold}

          -> To translate a word in context of a sentence, you should write the sentence and wrap the word in slashes:
            #{Rainbow(EXECUTABLE_NAME + ' a /random/ sentence').blue.bold}
            In this example, the word 'random' will be translated in context of the sentence.

          #{Rainbow('----------------------------------------').yellow.bright}
        ")

        puts '', opts

        return unless WordSmith::Services::OpenAI.api_key.nil?

        return unless WordSmith::Services::OpenAI.api_key.nil?

        open_a_i_message = T.let("
                To use OpenAI, you need to set an API key and Org ID.
                You can set the API key using '#{EXECUTABLE_NAME} #{OPENAI_API_KEY_COMMAND} <key>'
                You can set the Org ID using '#{EXECUTABLE_NAME} #{OPENAI_ORG_ID_COMMAND} <key>'
              ", String)
        puts '', WordSmith::Helpers::Str.lstr_every_line(open_a_i_message)
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
