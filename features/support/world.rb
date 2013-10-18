module SecretsManagementWorld
  def rest_resource(service)
    options = { headers: { authorization: @token } }
    host = case service
    when :directory
      Conjur::Core::API.host
    when :authz
      Conjur::Authz::API.host
    when :authn
      Conjur::Authn::API.host
    else
      raise "Unrecognized service : #{service}"
    end
    RestClient::Resource.new(host, options)
  end
  
  def environment_id
    CGI.escape [ $config[:namespace], 'secrets' ].join('/')
  end
  
  def environment_path
    [ 'environments', environment_id ].join '/'
  end
  
  def login_as(login)
    @token = authorization_token(login)
  end
  
  def handle_rest_exception try, e
    if try
      require 'ostruct'
      OpenStruct.new.tap do |response|
        response.code = e.http_code  
      end
    else
      raise e
    end
  end
  
  def authorization_token(login)
    require 'conjur/api'
    key = api_key(login)
    
    login = if login =~ /host\/(.*)/
      [ 'host', $config[:namespace], $1 ].join('/')
    else
      [ $config[:namespace], login ].join('-')
    end
    
    api = Conjur::API.new_from_key(login, key)
    token = api.token
    "Token token=\"#{Base64.strict_encode64 token.to_json}\""
  end
  
  def api_key(login)
    config_key = login.gsub('/', '_').to_sym
    $config[:api_keys][config_key] or raise "No API key for #{login}"
  end
end

World(SecretsManagementWorld, RSpec::Expectations, RSpec::Matchers)
