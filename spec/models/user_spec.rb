require 'rails_helper'

RSpec.describe User, type: :model do
  it "is valid with true/false guest attribute and an email" do
    guest_user = User.new(guest: true, email: "guest_#{Time.now.to_i}#{rand(100)}@example.com", password: "example")
    sign_in_user = User.new(guest: false, email: "example@example.com", password: "example")
    expect(guest_user).to be_valid
    expect(sign_in_user).to be_valid
  end

  it "is invalid without guest attribute" do
    user_without_guest_attr = User.new(guest: nil, email: "guest_#{Time.now.to_i}#{rand(100)}@example.com", password: "example")
    user_without_guest_attr.valid?
    expect(user_without_guest_attr.errors[:guest]).to include("is not included in the list")
  end

  it "is invalid without an email" do
    user_without_an_email = User.new(guest: true, email: nil, password: "example")
    user_without_an_email.valid?
    expect(user_without_an_email.errors[:email]).to include("can't be blank")
  end

  it "is invalid with a duplicated email" do
    User.create(guest: true, email: "guest_00000000000@example.com", password: "example")
    duplicated_user = User.new(guest: true, email: "guest_00000000000@example.com", password: "example")
    duplicated_user.valid?
    expect(duplicated_user.errors[:email]).to include("has already been taken")
  end

  it "is a valid email for guest users that composed of guest_ + [11 or 12-digit number] + @example.com" do
    guest_user_with_11_digit_num_in_email = User.new(guest: true, email: "guest_00000000000@example.com", password: "example")
    guest_user_with_12_digit_num_in_email = User.new(guest: true, email: "guest_999999999999@example.com", password: "example")
    expect(guest_user_with_11_digit_num_in_email).to be_valid
    expect(guest_user_with_12_digit_num_in_email).to be_valid
  end

  it "is an invalid email for guest users that composed of guest_ + [10 or 13-digit number] + @example.com" do
    guest_user_with_10_digit_num_in_email = User.new(guest: true, email: "guest_0000000000@example.com", password: "example")
    guest_user_with_13_digit_num_in_email = User.new(guest: true, email: "guest_9999999999999@example.com", password: "example")
    guest_user_with_10_digit_num_in_email.valid?
    guest_user_with_13_digit_num_in_email.valid?
    expect(guest_user_with_10_digit_num_in_email.errors[:email]).to include("is invalid")
    expect(guest_user_with_13_digit_num_in_email.errors[:email]).to include("is invalid")
  end
end
