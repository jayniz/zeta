require 'yaml'
require 'active_support/core_ext/hash/indifferent_access'
require 'old-maid/version'

class OldMaid
  attr_reader :config

  def initialize(config_file, env)
    full_config = YAML.load_file(config_file).with_indifferent_access
    @config = full_config[env]
  end

  def update_contracts

  end

  def validate_contracts
  end
end
