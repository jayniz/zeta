require 'spec_helper'

describe OldMaid do
  let(:config_file){ File.expand_path(File.join(__FILE__, '..', 'support', 'config.yml')) }
  let(:old_maid){ OldMaid.new(config_file, :test) }

  it 'has a version number' do
    expect(OldMaid::VERSION).not_to be nil
  end

  it 'loads a config file' do
    expect(old_maid.config,).to_not be nil
  end
end
