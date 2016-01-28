require 'lacerda/reporters/rspec'
require 'zeta'

# Include this file in your spec/spec_helper.rb
class Zeta::RSpec
  def self.ensure_contracts_present(force = false)
    Zeta.verbose = false
    if force || !File.directory?(Zeta.cache_dir)
      update_contracts
    end
  end

  def self.update_contracts
    RSpec.describe "Update Zeta infrastructure once" do
      it "download infrastructure" do
        expect{
          Zeta.config
        }.to_not raise_error
      end
  
      it "download specifications" do
        expect{
          Zeta.update_contracts
        }.to_not raise_error
      end
    end
  end

  def self.run
    Zeta.verbose = false
    ensure_contracts_present
    Zeta.update_contracts
    Zeta.contracts_fulfilled?(Lacerda::Reporters::RSpec.new)
  end
end
