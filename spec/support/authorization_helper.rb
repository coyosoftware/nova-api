module AuthorizationHelper
  def authorization_header
    { 'Persistent-Token': Nova::API.configuration.api_key }
  end
end