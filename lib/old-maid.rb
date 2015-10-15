require 'forwardable'
require 'old-maid/version'
require 'old-maid/instance'

class OldMaid
  include OldMaid::Instance
  extend SingleForwardable
  MUTEX = Mutex.new

  def self.instance
    MUTEX.synchronize do
      return @instance if @instance
      @instance = new
    end
  end

  def_delegators(*[:instance, OldMaid::Instance.instance_methods].flatten)
end


