class UsersController < ApplicationController
  def index
    @user = current_or_guest_user
  end
end
