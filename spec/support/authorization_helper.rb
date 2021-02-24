module AuthorizationHelper
  def authorization_header
    { HTTP_PERSISTENT_TOKEN: Nova::API.configuration.api_key }
  end
end