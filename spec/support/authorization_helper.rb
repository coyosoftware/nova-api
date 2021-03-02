module AuthorizationHelper
  def authorization_header
    { PERSISTENT_TOKEN: Nova::API.configuration.api_key }
  end
end