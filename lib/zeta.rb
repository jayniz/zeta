require 'forwardable'
require 'zeta/version'
require 'zeta/instance'

class Zeta
  include Zeta::Instance
  MUTEX = Mutex.new

  # Not using the SingleForwardable module here so that, when
  # somebody tries to figure out how Zeta works by looking at
  # its methods, they don't get confused.
  methods = Zeta::Instance.instance_methods - Object.instance_methods
  methods.each do |method|
    define_singleton_method method do |*args|
      send_args = [method, args].flatten.compact
      MUTEX.synchronize do
        unless @singleton
          # Create a Zeta singleton
          @singleton = new(verbose: true)

          # Copy the current service's specifications to cache dir
          @singleton.update_own_contracts

          # Convert current service's specifications so published and
          # consumed objects of this service can be validated at
          # runtime
          @singleton.infrastructure.convert_all!
        end
        @singleton.send(*send_args)
      end
    end
  end
end


