# frozen_string_literal: true

# Top level module on which the configuration will be applied.
module CursorPager
  # Encapulates all the configuration for the library.
  class Configuration
    # The encoder that will be used to encode & decode cursors.
    attr_accessor :encoder

    def initialize
      @encoder = Base64Encoder
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configuration=(config)
    @configuration = config
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
