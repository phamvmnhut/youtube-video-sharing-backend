module AuthenticateHelper
  def authenticate_user
    begin
      decode = JsonWebTokenService.decode(request.headers['HTTP_AUTH_TOKEN'])
      email = decode['email']
      @current_user = User.find_by(email: email)
    rescue JWT::DecodeError
      render json: { error: 'Not Authorized' }, status: :unauthorized
      @current_user = nil
    end
  end

  def self.authenticate_user_for_channel encoded
    begin
      decode = JsonWebTokenService.decode(encoded)
      email = decode['email']
      @current_user = User.find_by(email: email)
    rescue JWT::DecodeError
      @current_user = nil
    end
  end

  def user_sign_in?
    !!current_user
  end
  def current_user
    @current_user
  end
end