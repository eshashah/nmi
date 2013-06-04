require "nmi/configuration"
require "nmi/payment"
require "nmi/payment_error"
require "nmi/version"

module Nmi
  class << self
    def log *args
      self.config.logger.__send__(self.config.log_level, *args) if self.config.logger
    end
  end
end
