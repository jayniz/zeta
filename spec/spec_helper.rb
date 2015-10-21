$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'bundler'
Bundler.require
require 'webmock/rspec'
require 'old-maid'

require 'coveralls'
Coveralls.wear!
