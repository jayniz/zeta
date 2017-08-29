require 'lacerda/reporters/rspec'
require 'zeta'

if defined?(Rails) && ENV['ZETA_HTTP_USER'].blank? && ENV['ZETA_HTTP_PASSWORD'].blank?
  ENV['ZETA_HTTP_USER'] = Rails.application.config_for(:zeta)['user']
  ENV['ZETA_HTTP_PASSWORD'] = Rails.application.config_for(:zeta)['api_key']
end

RSpec.describe 'Zeta infrastructure', order: :defined do
  context 'the current service' do
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
  end

  context 'contract validation' do
    Zeta.contracts_fulfilled?(Lacerda::Reporters::RSpec.new(self))
  end
end
