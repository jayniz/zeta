require 'lacerda/reporters/rspec'

# Include this file in your spec/spec_helper.rb
class Zeta
  def self.run_specs
    Zeta.verbose = false
    unless File.directory?(Zeta.cache_dir)
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
    Zeta.contracts_fulfilled?(Lacerda::Reporters::RSpec.new)
  end
end
