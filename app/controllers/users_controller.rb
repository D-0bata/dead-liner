class UsersController < ApplicationController
  def current_or_guest_user
    @user = super
  end
end
