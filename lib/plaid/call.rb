module Plaid
  class Call

    # This initializes our instance variables, and sets up a new Customer class.
    def initialize
      Plaid::Configure::KEYS.each do |key|
        instance_variable_set(:"@#{key}", Plaid.instance_variable_get(:"@#{key}"))
      end
    end

    # This is a specific route for auth,
    # it returns specific acct info
    def add_account_auth(type, username, password, email)
      parse_auth_response(post('/auth', type, username, password, email))
    end

    # This is a specific route for connect,
    # it returns transaction information
    def add_account_connect(type,username,password,email,options={})
      parse_connect_response(post('/connect',type,username,password,email,options))
    end

    #deprecated
    def get_place(id)
      parse_place(get('/entities/',id))
    end

    def get_institutions
      JSON.parse(get('/institutions'))
    end

    def get_categories
      parse_categories(get('/categories'))
    end

    protected

    # Specific parser for auth response
    def parse_auth_response(response)
      parsed = JSON.parse(response)
      case response.code
      when 200
        {code: response.code, access_token: parsed['access_token'], accounts: parsed['accounts']}
      when 201
        {code: response.code, type: parsed['type'], access_token: parsed['access_token'], mfa: parsed['mfa']}
      else
        {code: response.code, message: parsed}
      end
    end

    def parse_connect_response(response)
      parsed = JSON.parse(response)
      case response.code
      when 200
        {code: response.code, access_token: parsed['access_token'], accounts: parsed['accounts'], transactions: parsed['transactions']}
      when 201
        {code: response.code, type: parsed['type'], access_token: parsed['access_token'], mfa: parsed['mfa']}
      else
        {code: response.code, message: parsed}
      end
    end

    # deprecated
    def parse_place(response)
      parsed = JSON.parse(response)
      {code: response.code, place: parsed}
    end

    def parse_institutions(response)
      parsed = JSON.parse(response)
      {code: response.code, institutions: parsed}
    end

    def parse_categories(response)
      parsed = JSON.parse(response)
      {code: response.code, categories: parsed}
    end

    private

    def post(path,type,username,password,email,options={})
      url = self.instance_variable_get(:'@url') + path
      RestClient.post url, client_id: self.instance_variable_get(:'@customer_id') ,secret: self.instance_variable_get(:'@secret'), type: type ,credentials: {username: username, password: password} ,email: email, options: options
    end

    def get(path,id = nil)
      url = self.instance_variable_get(:'@url') + path + id.to_s
      RestClient.get(url)
    end

  end
end
