module Plaid
  module Configure
    attr_writer :customer_id, :secret, :url

    KEYS = [:customer_id, :secret, :url]

    def config
      yield self
      self
    end

  end
end
