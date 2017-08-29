require 'lacerda/reporters/rspec'
require 'zeta'

if defined?(Rails) && ENV['ZETA_HTTP_USER'].blank? && ENV['ZETA_HTTP_PASSWORD'].blank?
  ENV['ZETA_HTTP_USER'] = Rails.application.config_for(:zeta)['user']
  ENV['ZETA_HTTP_PASSWORD'] = Rails.application.config_for(:zeta)['api_key']
end

RSpec.describe 'Zeta infrastructure', order: :defined do
  it 'is correctly configured' do
    expect do
      Zeta.config
      Zeta.infrastructure
    end.to_not raise_error
  end

  it 'can download the infrastructure contracts (requires network connection)' do
    expect do
      Zeta.verbose = false
      Zeta.update_contracts
    end.to_not raise_error
  end

  # This is a bit odd. The RSpec reporter declares new describes inside. That
  # fails usually in RSpec, but not in the way we're doing it.
  # We need it because if this `it` would be a `context`, `contracts_fulfilled?`
  # would be already evaluated before the previous examples run. This would
  # make that this example fails, because the contracts have not been
  # downloaded yet
  it 'has a valid infrastructure' do
    expect(Zeta.contracts_fulfilled?(Lacerda::Reporters::RSpec.new)).to eq true
  end
end
