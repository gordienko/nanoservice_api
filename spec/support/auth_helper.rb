module AuthHelper
  def http_login
    username = Rails.application.credentials.dig(:username)
    password = Rails.application.credentials.dig(:password)
    {
        HTTP_AUTHORIZATION: ActionController::HttpAuthentication::
                Basic.encode_credentials(username, password)
    }
  end
end
