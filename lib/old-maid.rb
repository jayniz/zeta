require 'forwardable'
require 'old-maid/version'
require 'old-maid/instance'

class OldMaid
  include OldMaid::Instance
  MUTEX = Mutex.new

  # Not using the SingleForwardable module here so that, when
  # somebody tries to figure out how OldMaid works by looking at
  # its methods, they don't get confused.
  OldMaid::Instance.instance_methods.each do |method|
    define_singleton_method method do |*args|
      send_args = [method, args].flatten.compact
      MUTEX.synchronize do
        @singleton ||= new
        @singleton.send(*send_args)
      end
    end
  end
end


