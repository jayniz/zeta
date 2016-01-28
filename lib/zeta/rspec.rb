require 'lacerda/reporters/rspec'
require 'zeta'

# Include this file in your spec/spec_helper.rb
class Zeta::RSpec
  def self.update_contracts
    RSpec.describe "Update Zeta infrastructure once" do
      it "download infrastructure" do
        expect{
          Zeta.config
        }.to_not raise_error
      end
  
      it "download specifications" do
        expect{
          # Zeta.verbose = false
          Zeta.update_contracts
        }.to_not raise_error
      end

      it "validate infrastructure" do
        Zeta.contracts_fulfilled?(Lacerda::Reporters::RSpec.new)
      end
    end
  end
end
