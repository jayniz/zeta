require 'lacerda/reporters/rspec'
require 'zeta'

# Include this file in your spec/spec_helper.rb
class Zeta::RSpec
  def self.run
    RSpec.describe "Update Zeta infrastructure once", order: :defined do
      it "download infrastructure (requires network connection)" do
        expect{
          Zeta.config
          Zeta.infrastructure
        }.to_not raise_error
      end

      it "download specifications (requires network connection)" do
        expect{
          Zeta.verbose = false
          Zeta.update_contracts
        }.to_not raise_error
      end

      it "validate infrastructure" do
        Zeta.contracts_fulfilled?(Lacerda::Reporters::RSpec.new)
      end
    end
  end
end
