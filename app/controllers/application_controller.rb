class ApplicationController < ActionController::API
  include AuthenticateHelper
  before_action :authenticate_user
end
