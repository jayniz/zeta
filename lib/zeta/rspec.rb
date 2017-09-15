require 'lacerda/reporters/rspec'
require 'zeta'

class Zeta::RSpec
  def self.run
    # Download Infrastructure
    Zeta.config
    Zeta.infrastructure

    # Update Contracts
    Zeta.verbose = false
    Zeta.update_contracts

    # Validate Infrastructure
    # NOTE: Expectations are defined by .contracts_fulfilled?
    #
    # Whats the structure of this expectations?
    # https://github.com/moviepilot/lacerda/blob/master/lib/lacerda/reporters/rspec.rb
    #
    Zeta.contracts_fulfilled?(Lacerda::Reporters::RSpec.new)
  end
end
