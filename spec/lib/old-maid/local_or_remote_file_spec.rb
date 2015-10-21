require 'spec_helper'
require 'fileutils'

describe OldMaid::LocalOrRemoteFile do
  it "refuses to open a file it doesn't know how to locate" do
    expect{
      OldMaid::LocalOrRemoteFile.new({}).read
    }.to raise_error{ |e|
      expect(e.to_s.include?("Unknown file location")).to be true
    }
  end

  it "loads a local file" do
    dir = Dir.mktmpdir
    timestamp = Time.now.to_i
    begin
      file = File.join(dir, 'test.mson')
      File.open(file, 'w'){ |f| f.print timestamp }
      o = {
        file: 'test.mson',
        path: dir
      }
      expect(OldMaid::LocalOrRemoteFile.new(o).read).to eq timestamp.to_s
    ensure
      FileUtils.remove_entry dir
    end
  end

  context "loading from github" do
    let(:get_double){double(to_s: 'Something', code: 200)}
    let(:o){{
      file: 'foo.txt',
      github: { user: 'user', repo: 'repo', path: 'path' }
    }}

    it "without auth tokens" do
      expect(HTTParty).to receive(:get).with("https://raw.githubusercontent.com/repo/path/foo.txt").and_return(get_double)
      OldMaid::LocalOrRemoteFile.new(o).read
    end

    it "with auth tokens" do
      ENV['GITHUB_USER'] = 'user'
      ENV['GITHUB_TOKEN'] = 'token'
      begin
        expect(HTTParty).to receive(:get).with("https://user:token@raw.githubusercontent.com/repo/path/foo.txt").and_return(get_double)
        OldMaid::LocalOrRemoteFile.new(o).read
      ensure
        ENV['GITHUB_USER'] = nil
        ENV['GITHUB_TOKEN'] = nil
      end
    end

    it "raises a 404" do
      not_found = double(to_s: 'Something', code: 404)
      expect(HTTParty).to receive(:get).with("https://raw.githubusercontent.com/repo/path/foo.txt").and_return(not_found)

      expect {
        OldMaid::LocalOrRemoteFile.new(o).read
      }.to raise_error{ |e|
        expect(e.to_s.end_with?("Error 404")).to be true
      }
    end
  end
end
