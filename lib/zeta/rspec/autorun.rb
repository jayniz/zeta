require 'lacerda/reporters/rspec'
require 'zeta'

if defined?(Rails) && ENV['ZETA_HTTP_USER'].blank? && ENV['ZETA_HTTP_PASSWORD'].blank?
  ENV['ZETA_HTTP_USER'] = Rails.application.config_for(:zeta).fetch('user')
  ENV['ZETA_HTTP_PASSWORD'] = Rails.application.config_for(:zeta).fetch('api_key')
end

RSpec.describe "Zeta infrastructure", order: :defined do
  it "has a correctly configured current service" do
    expect{
      Zeta.config
      Zeta.infrastructure
    }.to_not raise_error
  end

  it "can download the infrastructure contracts (requires network connection)" do
    expect{
      Zeta.verbose = false
      Zeta.update_contracts
    }.to_not raise_error
  end

  it "has a valid infrastructure" do
    expect(Zeta.contracts_fulfilled?(Lacerda::Reporters::RSpec.new)).to eq true
  end
end
