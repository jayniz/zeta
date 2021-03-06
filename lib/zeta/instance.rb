require 'active_support/core_ext/hash/indifferent_access'
require 'yaml'
require 'fileutils'
require 'tmpdir'
require 'lacerda'

require 'zeta/local_or_remote_file'

class Zeta
  module Instance
    attr_reader :config

    def initialize(options = {})
      @lock = Monitor.new
      @options = options
    end

    def update_contracts
      @lock.synchronize do
        i = infrastructure
        clear_cache
        puts "Updating #{cache_dir}" if verbose?
        update_other_contracts
        update_own_contracts
        i.convert_all!
      end
      true
    end

    def convert_all!
      @lock.synchronize do
        infrastructure.convert_all!
      end
    end

    def update_own_contracts
      @lock.synchronize do
        contract_files.each do |file|
          source_file = File.join(config[:contracts_path], file)
          target_file = File.join(cache_dir, config[:service_name], file)
          FileUtils.mkdir_p(File.join(cache_dir, config[:service_name]))
          puts "cp #{source_file} #{target_file}" if verbose?
          FileUtils.rm_f(target_file)
          FileUtils.cp(source_file, target_file) if File.exists?(source_file)
        end
      end
    end

    def errors
      infrastructure.errors
    end

    def contracts_fulfilled?(reporter = nil)
      reporter ||= Lacerda::Reporters::Stdout.new(verbose: verbose?)
      infrastructure.contracts_fulfilled?(reporter)
    end

    def infrastructure
      @lock.synchronize do
        return @infrastructure if @infrastructure
        @infrastructure = Lacerda::Infrastructure.new(data_dir: cache_dir, verbose: verbose?)
        @infrastructure
      end
    end

    def config_file
      return File.expand_path(@options[:config_file]) if @options[:config_file]
      File.join(Dir.pwd, 'config', 'zeta.yml')
    end

    def env
      return @options[:env].to_sym if @options[:env]
      if Object.const_defined?('Rails')
        Rails.env.to_sym
      else
        guessed = ENV['RAILS_ENV'] || ENV['RACK_ENV']
        raise "No environment given" unless guessed
        guessed
      end
    end

    def cache_dir
      @lock.synchronize do
        return @cache_dir if @cache_dir
        full_path = File.expand_path(config[:contracts_cache_path])
        FileUtils.mkdir_p(full_path)
        @cache_dir = full_path
      end
    end

    def clear_cache
      @lock.synchronize do
        # I'm afraid of FileUtils.rm_rf so I'll just delete all relevant files
        # and then rmdir all empty directories.
        Dir[File.join(cache_dir, "**/*.mson")].each{|f| FileUtils.rm(f) }
        Dir[File.join(cache_dir, "**/*.json")].each{|f| FileUtils.rm(f) }
        Dir[File.join(cache_dir, '*')].each do |d|
          next unless File.directory?(d)
          FileUtils.rmdir(d) rescue nil
        end
      end
    end

    def config
      @lock.synchronize do
        return @config if @config
        full_config = YAML.load_file(config_file).with_indifferent_access
        env_config  = full_config[env]

        raise "No config for environment '#{env}' found in #{config_file}" unless env_config

        # TODO validate it properly
        [:service_name, :contracts_path, :contracts_cache_path].each do |k|
          raise ":#{k} missing in #{full_config.to_json}" unless env_config[k]
        end

        @config = env_config
      end
    end

    def validate_object_to_publish!(type, data)
      current_service.validate_object_to_publish!(type, data)
    end

    def validate_object_to_publish(type, data)
      current_service.validate_object_to_publish(type, data)
    end

    def validate_object_to_consume!(type, data)
      current_service.validate_object_to_consume!(type, data)
    end

    def validate_object_to_consume(type, data)
      current_service.validate_object_to_consume(type, data)
    end

    def consume_object(type, data)
      current_service.consume_object(type, data)
    end

    def current_service
      @current_service ||= infrastructure.services[config[:service_name]]
    end

    def verbose=(val)
      @options[:verbose] = !!val
    end

    private

    def verbose?
      @options[:verbose]
    end

    def fetch_service_contracts(service_name, config)
      target_dir = File.join(cache_dir, service_name)
      FileUtils.mkdir_p(target_dir)

      contract_files.each do |contract|
        file = File.join(target_dir, contract)
        FileUtils.rm_f(file)

        File.open(file, 'w') do |out|
          contract = LocalOrRemoteFile.new(config.merge(file: contract, verbose: verbose?)).read
          raise "Invalid contract:\n\n#{contract}\n#{'~'*80}" unless contract_looks_valid?(contract)
          out.puts contract
        end
      end
    end

    def contract_looks_valid?(contract)
      true # TODO
    end

    def update_other_contracts
      services.each do |service_name, config|
        fetch_service_contracts(service_name, config)
      end
    end

    def contract_files
      ['publish.mson', 'consume.mson']
    end

    def services
      if config[:services]
        return config[:services]
      elsif config[:services_file]
        file = LocalOrRemoteFile.new(config[:services_file].merge(verbose: verbose?))
        services = YAML.load(file.read)
        begin
          services.with_indifferent_access
        rescue
          raise "Could not load services from #{config[:services_file].to_json}"
        end
      end
    end

  end
end
