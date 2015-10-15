require 'active_support/core_ext/hash/indifferent_access'
require 'yaml'
require 'fileutils'
require 'tmpdir'

require 'old-maid/version'
require 'old-maid/local_or_remote_file'

class OldMaid
  attr_reader :config, :dir

  def initialize(params)
    @params = params
    full_config = YAML.load_file(config_file).with_indifferent_access
    validate_config(full_config[env])
    init_contracts_dir
  end

  def update_contracts
    update_other_contracts
    copy_own_contract
  end

  def validate_contracts
    # TODO
  ensure
    remove_temp_dir
  end

  def remove_temp_dir
    FileUtils.remove_entry_secure(@dir)
  end

  def config_file
    return File.expand_path(@params[:config_file]) if @params[:config_file]
    File.join(Dir.pwd, 'config', 'old-maid.yml')
  end

  def env
    return @params[:env].to_sym if @params[:env]
    return unless Object.const_defined?('Rails')
    Rails.env.to_sym
  end

  private

  def validate_config(config)
    @config = config
    # TODO validate it
  end

  def fetch_service_contracts(service_name, config)
    target_dir = File.join(@dir, service_name)
    FileUtils.mkdir_p(target_dir)

    contract_files.each do |contract|
      file = File.join(target_dir, contract)
      FileUtils.rm_f(file)

      File.open(file, 'w') do |out|
        out.puts LocalOrRemoteFile.new(config.merge(file: contract)).read
      end
    end
  end

  def init_contracts_dir
    @dir ||= Dir.mktmpdir(@config[:service_name])
  end

  def update_other_contracts
    services.each do |service_name, config|
      puts service_name
      fetch_service_contracts(service_name, config)
    end
  end

  def copy_own_contract

  end

  def contract_files
    ['publish.mson', 'consume.mson']
  end

  def services
    if @config[:services]
      return @config[:services]
    elsif @config[:services_file]
      file = LocalOrRemoteFile.new(@config[:services_file])
      services = YAML.load(file.read)
      begin
        services.with_indifferent_access
      rescue
        raise "Could not load services from #{services.to_json}"
      end
    end
  end

end
