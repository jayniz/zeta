require 'spec_helper'

describe Contractor do
  let(:config_file){ File.expand_path(File.join(__FILE__, '..', 'support', 'config.yml')) }
  let(:contractor){ Contractor.new(config_file, :test) }

  it 'has a version number' do
    expect(Contractor::VERSION).not_to be nil
  end

  it 'loads a config file' do
    expect(contractor.config,).to_not be nil
  end
end
