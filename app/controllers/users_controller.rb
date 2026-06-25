class UsersController < ApplicationController
  def current_or_guest_user
    @user = super
    redirect_to controller: :tasks, action: :index
  end
end
