require 'httparty'
require 'open-uri'

require 'pry'

class OldMaid::LocalOrRemoteFile
  def initialize(params)
    @params = params
  end

  def read
    if @params[:path]
      read_local
    elsif @params[:github]
      read_from_github
    else
      raise "Unknown file location #{@params}"
    end
  end

  private

  def read_local
    open(File.join(@params[:path], @params[:file])).read
  end

  def read_from_github
    HTTParty.get github_url
  end

  def github_url
    repo   = @params[:github][:repo]
    branch = @params[:github][:branch]
    path   = @params[:github][:path]
    file   = @params[:file]

    uri = [branch, path, file].compact.join('/')
    if u = ENV['GITHUB_USER'] && t = ENV['GITHUB_TOKEN']
      "https://#{u}:#{t}@raw.githubusercontent.com/#{repo}/#{uri}"
    else
      "https://raw.githubusercontent.com/#{repo}/#{uri}"
    end
  end
end
