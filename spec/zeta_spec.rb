require 'spec_helper'

describe Zeta do
  let(:config_file){ File.expand_path(File.join(__FILE__, '..', 'support', 'config.yml')) }
  let(:zeta){
    z = Zeta.new(config_file: config_file, env: :with_inline_services)
    z.verbose = false
    z
  }

  after(:all) do
    # Clean up
    FileUtils.rm_rf(File.join(Dir.pwd, 'spec', 'support', 'contracts', 'valid', '.cache'))
    FileUtils.rm_rf(File.join(Dir.pwd, 'spec', 'support', 'contracts', 'valid', '.cache'))
  end

  it 'has a version number' do
    expect(Zeta::VERSION).not_to be nil
  end

  context "singleton" do
    it "creates a singleton with a default config on demand" do
      zeta = Zeta.new(verbose: false)
      expect(Zeta).to receive(:new).and_return(zeta)
      expect(zeta).to receive(:errors).and_return([])

      expect(Zeta.errors).to eq []
    end
  end

  context "defaults" do

    it "config_file in config/zeta.yml" do
      default = File.join(Dir.pwd, 'config', 'zeta.yml')
      expect{
        m = Zeta.new(env: :master, verbose: false)
        m.update_contracts
      }.to raise_error do |error|
        expect(error.message.include?(default)).to be true
      end
    end

    context "environment" do

      it "rails env, if defined" do
        begin
          class Rails
            def self.env
              :rails_env
            end
          end
          m = Zeta.new(config_file: config_file)
          expect(m.env).to eq :rails_env
        ensure
          Object.send(:remove_const, :Rails)
        end
      end

      it "RAILS_ENV environment variable" do
        ENV['RAILS_ENV'] = 'FOO'
        begin
          m = Zeta.new(config_file: config_file, verbose: false)
          expect(m.env).to eq 'FOO'
        rescue
          ENV['RAILS_ENV'] = nil
        end
      end

      it "RACK_ENV environment variable" do
        ENV['RACK_ENV'] = 'FOO'
        begin
          m = Zeta.new(config_file: config_file, verbose: false)
          expect(m.env).to eq 'FOO'
        rescue
          ENV['RACK_ENV'] = nil
        end
      end
    end
  end

  context "delegating to" do
    let(:z){Zeta.new(env: :with_remote_services_list, config_file: config_file, verbose: false)}

    context "infrastructure" do
      it ":errors" do
        expect(z.infrastructure).to receive(:errors).and_return [:foo]
        expect(z.errors).to eq [:foo]
      end
    end

    context "current service" do
      let(:services_double) { { 'test_service' => double(Lacerda::Service) } }
      # These should all just be forwarded to the current service

      context "validating objects" do
        methods = [
          :validate_object_to_publish,
          :validate_object_to_publish!,
          :validate_object_to_consume,
          :validate_object_to_consume!,
          :consume_object
        ]
        methods.each do |m|
          it m do
            expect(z.infrastructure).to receive(:services).and_return(services_double)
            expect(services_double['test_service']).to receive(m)
              .with(:type, :data).and_return :result
            expect(z.send(m, :type, :data)).to eq :result
          end
        end
      end
    end
  end


  context "list of services defined inline in yaml" do

    it 'complains when no services could be found for an env' do
      get_double = double(to_s: '', code: 200)
      url = 'https://raw.githubusercontent.com/username/repo/master/missing.yml'
      o = {config_file: config_file, env: :missing_services, verbose: false}
      expect(HTTParty).to receive(:get).with(url).and_return(get_double)

      zeta = Zeta.new(o)
      expect{
        zeta.send(:services)
      }.to raise_error{ |e|
        expected = "Could not load services from"
        expect(e.to_s.include?(expected)).to be true
      }
    end

    it 'loads a config file' do
      expect(zeta.config).to_not be nil
    end

    it 'updates the contracts' do
      get_double = double(to_s: '#Data structures', code: 200)
      urls = [
        "https://raw.githubusercontent.com/username/service_1/master/contracts/consume.mson",
        "https://raw.githubusercontent.com/username/service_1/master/contracts/publish.mson",
        "https://raw.githubusercontent.com/username/service_2/production/contracts/publish.mson",
        "https://raw.githubusercontent.com/username/service_2/production/contracts/consume.mson",
      ]
      urls.each do |url|
        expect(HTTParty).to receive(:get).with(url).and_return(get_double)
      end

      zeta.update_contracts
    end
  end

  context "list of services defined in a remote file" do
    let(:zeta){ Zeta.new(config_file: config_file, env: :with_remote_services_list, verbose: false)}
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
      expect(Zeta::VERSION).not_to be nil
    end

    it 'loads a config file' do
      expect(zeta.config,).to_not be nil
    end

    it 'updates the contracts' do
      expect(Zeta::LocalOrRemoteFile).to receive(:http_get).with(services_url, false).and_return(remote_services_list)
      urls = [
        "https://raw.githubusercontent.com/username/service_1/master/contracts/consume.mson",
        "https://raw.githubusercontent.com/username/service_1/master/contracts/publish.mson",
        "https://raw.githubusercontent.com/username/service_2/production/contracts/publish.mson",
        "https://raw.githubusercontent.com/username/service_2/production/contracts/consume.mson",
      ]
      urls.each do |url|
        expect(Zeta::LocalOrRemoteFile).to receive(:http_get).with(url, false).and_return("# Data structures")
      end

      zeta.update_contracts
    end
  end

  context 'validating the contracts' do
    it "TODO" do
      expect(zeta.contracts_fulfilled?).to be true
    end

  end
end
