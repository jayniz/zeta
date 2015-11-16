# encoding: UTF-8
require 'optparse'

class Zeta::Runner
  COMMANDS = {
    'full_check'             => 'Update contracts and validate infrastructure',
    'validate'               => 'Validate the architecture in the contracts cache dir',
    'update_own_contracts'   => 'Update your own contracts in the contracts cache dir',
    'fetch_remote_contracts' => 'Download remote contracts and update your own contracts in the contracts cache dir'
  }

  def self.run
    options = {}
    parser = OptionParser.new do |opts|
      opts.banner = "#{'Usage:'.red} zeta [options] command"

      opts.separator ""
      opts.separator "Commands:".yellow

      longest_command = COMMANDS.keys.map(&:length).sort.last + 1
      command_list = []
      COMMANDS.each do |cmd, desc|
        padded_cmd = "#{cmd}:".ljust(longest_command, " ")
        command_list << "    #{padded_cmd} #{desc}"
      end
      opts.separator command_list

      opts.separator ""
      opts.separator "Specific options:".yellow

      opts.on("-c CONFIG_FILE", "--config=CONFIG_FILE", "Config file (default: config/zeta.yml)") do |c|
        options[:config_file] = c
      end

      opts.on("-e ENVIRONMENT", "--env=ENVIRONMENT", "Environment (default: RAILS_ENV, if it is set)") do |e|
        options[:env] = e
      end

      opts.on("-s", "--silent", "No output, just an appropriate return code") do |s|
        options[:silent] = s
      end

      opts.on("-t", "--trace", "Print exception stack traces") do |t|
        options[:trace] = t
      end

      opts.separator ""
      opts.separator "Common options:".yellow

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
    if commands.empty? or !(commands-COMMANDS.keys).empty?
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
          exit(-1)
        end
      end
    rescue => e
      if options[:trace]
        raise
      else
        puts "ERROR: ".red + e.message
        puts "(Pssst: try the "+"--trace".yellow+" option?)"
      end
      exit(-1)
    end
  end
end
