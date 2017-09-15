if defined?(Rails) && Rails.application.config_for(:zeta).present?
  ENV['ZETA_HTTP_USER'] ||= Rails.application.config_for(:zeta)['user']
  ENV['ZETA_HTTP_PASSWORD'] ||= Rails.application.config_for(:zeta)['api_key']
end

require 'zeta/rspec'

Zeta::RSpec.run
