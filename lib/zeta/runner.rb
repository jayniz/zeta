# encoding: UTF-8
require 'optparse'

class Zeta::Runner
  COMMANDS = %w{full_check fetch_remote_contracts update_own_contracts validate}

  def self.run
    options = {}
    parser = OptionParser.new do |opts|
      opts.banner = "Usage: zeta [options] #{COMMANDS.join('|')}"

      opts.separator ""
      opts.separator "Specific options:"

      opts.on("-c CONFIG_FILE", "--config=CONFIG_FILE", "Config file (default: config/zeta.yml)") do |c|
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
        puts Zeta::VERSION
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
    zeta = Zeta.new(options)

    begin
      if commands.include?('fetch_remote_contracts') or commands.include?('full_check')
        zeta.update_contracts
        puts "\n" if options[:verbose]
      end

      if commands.include?('update_own_contracts')
        puts "Copying #{zeta.config[:service_name].to_s.camelize} contracts..." if options[:verbose]
        zeta.update_own_contracts
        puts "\n" if options[:verbose]
      end

      if commands.include?('validate') or commands.include?('full_check')
        puts "Validating your infrastructure with #{zeta.infrastructure.publishers.length} publishers and #{zeta.infrastructure.consumers.length} consumers..." if options[:verbose]
        zeta.contracts_fulfilled?
        unless zeta.errors.empty?
          puts JSON.pretty_generate(zeta.errors)
          puts "#{zeta.errors.length} invalid contracts".red
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
