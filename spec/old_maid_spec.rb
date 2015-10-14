require 'spec_helper'

describe OldMaid do
  let(:config_file){ File.expand_path(File.join(__FILE__, '..', 'support', 'config.yml')) }

  context "list of services defined inline in yaml" do
    let(:old_maid){ OldMaid.new(config_file, :with_inline_services) }

    it 'has a version number' do
      expect(OldMaid::VERSION).not_to be nil
    end

    it 'loads a config file' do
      expect(old_maid.config,).to_not be nil
    end

    it 'updates the contracts' do
      urls = [
        "https://raw.githubusercontent.com/username/service_1/master/contracts/consume.mson",
        "https://raw.githubusercontent.com/username/service_1/master/contracts/publish.mson",
        "https://raw.githubusercontent.com/username/service_2/production/contracts/publish.mson",
        "https://raw.githubusercontent.com/username/service_2/production/contracts/consume.mson",
      ]
      urls.each do |url|
        expect(HTTParty).to receive(:get).with(url).and_return("Some MSON")
      end

      old_maid.update_contracts
    end

    context 'validating the contracts' do
      it "TODO" do
        old_maid.validate_contracts
      end
    end
  end

  context "list of services defined in a remote file" do
    let(:old_maid){ OldMaid.new(config_file, :with_remote_services_list) }
    let(:services_url){ "https://raw.githubusercontent.com/username/repo/master/services.yml" }
    let(:remote_services_list){
      <<YAML
service_1:
  github:
    repo: username/service_1
    branch: master
    path: contracts
service_2:
  github:
    repo: username/service_2
    branch: production
    path: contracts
YAML
    }

    it 'has a version number' do
      expect(OldMaid::VERSION).not_to be nil
    end

    it 'loads a config file' do
      expect(old_maid.config,).to_not be nil
    end

    it 'updates the contracts' do
      expect(HTTParty).to receive(:get).with(services_url).and_return(remote_services_list)
      urls = [
        "https://raw.githubusercontent.com/username/service_1/master/contracts/consume.mson",
        "https://raw.githubusercontent.com/username/service_1/master/contracts/publish.mson",
        "https://raw.githubusercontent.com/username/service_2/production/contracts/publish.mson",
        "https://raw.githubusercontent.com/username/service_2/production/contracts/consume.mson",
      ]
      urls.each do |url|
        expect(HTTParty).to receive(:get).with(url).and_return("Some MSON")
      end

      old_maid.update_contracts
    end

    context 'validating the contracts' do
      it "TODO" do
        old_maid.validate_contracts
      end
    end
  end
end
