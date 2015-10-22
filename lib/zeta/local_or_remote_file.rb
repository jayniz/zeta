require 'colorize'
require 'httparty'
require 'open-uri'

require 'pry'

class Zeta::LocalOrRemoteFile
  def initialize(options)
    @options = options
  end

  def read
    if @options[:path]
      read_local
    elsif @options[:github]
      read_from_github
    else
      raise "Unknown file location #{@options}"
    end
  end

  private

  def read_local
    open(File.join(@options[:path], @options[:file])).read
  end

  def read_from_github
    self.class.http_get(github_url, verbose?)
  end

  def self.http_get(url, verbose)
    masked_url = ENV['GITHUB_TOKEN'].blank? ? url : url.sub(ENV['GITHUB_TOKEN'], '***')
    print "GET #{masked_url}... " if verbose
    result = HTTParty.get url
    raise "Error #{result.code}" unless result.code == 200
    print "OK\n".green if verbose
    result.to_s
  rescue
    print "ERROR\n".blue if verbose
    raise
  end

  def verbose?
    !!@options[:verbose]
  end

  def github_url
    repo   = @options[:github][:repo]
    branch = @options[:github][:branch]
    path   = @options[:github][:path]
    file   = @options[:file]

    uri = [branch, path, file].compact.join('/')
    if u = ENV['GITHUB_USER'] and t = ENV['GITHUB_TOKEN']
      "https://#{u}:#{t}@raw.githubusercontent.com/#{repo}/#{uri}"
    else
      "https://raw.githubusercontent.com/#{repo}/#{uri}"
    end
  end
end