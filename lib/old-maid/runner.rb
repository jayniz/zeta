# encoding: UTF-8
require 'optparse'

class OldMaid::Runner
  COMMANDS = %w{full_check fetch_remote_contracts update_own_contracts validate}

  def self.run
    options = {}
    parser = OptionParser.new do |opts|
      opts.banner = "Usage: old-maid [options] #{COMMANDS.join('|')}"

      opts.separator ""
      opts.separator "Specific options:"

      opts.on("-c CONFIG_FILE", "--config=CONFIG_FILE", "Config file (default: config/old-maid.yml)") do |c|
        options[:config_file] = c
      end

      opts.on("-e ENVIRONMENT", "--env=ENVIRONMENT", "Environment (default: RAILS_ENV, if it is set)") do |e|
        options[:env] = e
      end

      opts.on("-s", "--silent", "No output, just an appropriate return code") do |s|
        options[:silent] = s
      end

      opts.separator ""
      opts.separator "Common options:"

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end

      # Another typical switch to print the version.
      opts.on_tail("-v", "--version", "Show version") do
        puts OldMaid::VERSION
        exit
      end
    end
    parser.parse!

    commands = ARGV
    if commands.empty? or !(commands-COMMANDS).empty?
      puts parser
      exit(-1)
    end

    options[:verbose] = !options.delete(:silent)
    maid = OldMaid.new(options)

    begin
      if commands.include?('fetch_remote_contracts') or commands.include?('full_check')
        maid.update_contracts
        puts "\n" if options[:verbose]
      end

      if commands.include?('update_own_contracts')
        puts "Copying #{maid.config[:service_name].to_s.camelize} contracts..." if options[:verbose]
        maid.update_own_contracts
        puts "\n" if options[:verbose]
      end

      if commands.include?('validate') or commands.include?('full_check')
        puts "Validating your infrastructure with #{maid.infrastructure.publishers.length} publishers and #{maid.infrastructure.consumers.length} consumers..." if options[:verbose]
        maid.contracts_fulfilled?
        unless maid.errors.empty?
          puts JSON.pretty_generate(maid.errors)
          puts "#{maid.errors.length} invalid contracts".red
          exit(-1)
        end
        puts "All contracts valid 🙌".green if options[:verbose]
      end
    rescue => e
      if options[:verbose]
        raise
      else
        puts "ERROR: ".red + e.message
      end
      exit(-1)
    end
  end
end
