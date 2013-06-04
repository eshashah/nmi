module Nmi
  class << self
    def config
      @config ||= Configuration.new
    end
  end

  def self.configure
    yield self.config
  end

  class Configuration
    attr_accessor :api_key, :username, :password
    attr_reader :logger, :log_level
    def initialize
      @logger = Rails.logger if defined?(::Rails)
      @log_level = :debug
    end
  end
end