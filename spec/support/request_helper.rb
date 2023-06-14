module RequestHelper
  def authenticated_header(user)
    auth_token = JsonWebTokenService.encode({ email: user.email })
    { HTTP_AUTH_TOKEN: auth_token }
  end
end
