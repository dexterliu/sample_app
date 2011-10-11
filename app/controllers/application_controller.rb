class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper   # this includes the helper
end
