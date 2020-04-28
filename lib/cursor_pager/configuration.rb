# frozen_string_literal: true

# Top level module on which the configuration will be applied.
module CursorPager
  # Encapulates all the configuration for the library.
  class Configuration
    # The encoder that will be used to encode & decode cursors.
    # Defaults to `Base64Encoder`.
    attr_accessor :encoder

    # The default page size that will be used if no `first` or `last` were
    # specified. Every record fitting the cursor constraints will be returned
    # if it's set to `nil`.
    # Defaults to `nil`.
    attr_accessor :default_page_size

    # The maximum allowed page size. Clients will never receive more records per
    # page than is sepcified here. There is no maximum if this is set to `nil`.
    # Defaults to `nil`.
    attr_accessor :maximum_page_size

    def initialize
      @encoder = Base64Encoder
      @default_page_size = nil
      @maximum_page_size = nil
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
