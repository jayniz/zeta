require 'forwardable'
require 'zeta/version'
require 'zeta/instance'

class Zeta
  include Zeta::Instance
  LOCK = Monitor.new

  def self.instance
    LOCK.synchronize do
      if @instance.nil?
        create_instance
      end
      @instance
    end
  end

  def self.create_instance(options = {verbose: true})
    LOCK.synchronize do
      # Create a Zeta instance
      @instance = new(options)

      # Copy the current service's specifications to cache dir
      @instance.update_own_contracts

      # Convert current service's specifications so published and
      # consumed objects of this service can be validated at
      # runtime
      @instance.convert_all!

      @instance
    end
  end

  # Not using the SingleForwardable module here so that, when
  # somebody tries to figure out how Zeta works by looking at
  # its methods, they don't get confused.
  methods = Zeta::Instance.instance_methods - Object.instance_methods
  methods.each do |method|
    define_singleton_method method do |*args|
      send_args = [method, args].flatten.compact
      instance.send(*send_args)
    end
  end
end


