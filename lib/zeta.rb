require 'forwardable'
require 'zeta/version'
require 'zeta/instance'

class Zeta
  include Zeta::Instance
  MUTEX = Mutex.new

  # Not using the SingleForwardable module here so that, when
  # somebody tries to figure out how Zeta works by looking at
  # its methods, they don't get confused.
  Zeta::Instance.instance_methods.each do |method|
    define_singleton_method method do |*args|
      send_args = [method, args].flatten.compact
      MUTEX.synchronize do
        @singleton ||= new(verbose: true)
        @singleton.send(*send_args)
      end
    end
  end
end


