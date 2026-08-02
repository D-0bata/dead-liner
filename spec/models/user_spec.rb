require 'rails_helper'

RSpec.describe User, type: :model do
  describe "create a user" do
    context "common between a guest user and a sign-in user" do
      it "has a valid factory" do
        # 「:user」と「:guest_user」はaliasの関係である。
        expect(FactoryBot.build(:user)).to be_valid
        expect(FactoryBot.build(:guest_user)).to be_valid
        expect(FactoryBot.build(:sign_in_user)).to be_valid
      end

      it "is valid with a guest flag and an email" do
        guest_user = FactoryBot.build(:guest_user)
        sign_in_user = FactoryBot.build(:sign_in_user)
        expect(guest_user).to be_valid
        expect(sign_in_user).to be_valid
      end
    end
  end

  describe "validate a guest flag" do
    context "as a guest user" do
      it "is invalid without a guest flag" do
        guest_user = FactoryBot.build(:guest_user, guest: nil)
        guest_user.valid?
        expect(guest_user.errors[:guest]).to include("is not included in the list")
      end
    end

    context "as a sign-in user" do
      it "is invalid without a guest flag" do
        sign_in_user = FactoryBot.build(:sign_in_user, guest: nil)
        sign_in_user.valid?
        expect(sign_in_user.errors[:guest]).to include("is not included in the list")
      end
    end
  end

  describe "validate an email" do
    context "as a guest user" do
      it "is invalid without an email" do
        guest_user = FactoryBot.build(:guest_user, email: nil)
        guest_user.valid?
        expect(guest_user.errors[:email]).to include("can't be blank")
      end

      it "is invalid with a duplicated email" do
        FactoryBot.create(:guest_user, email: "guest_#{"0" * 11}@example.com")
        guest_user = FactoryBot.build(:guest_user, email: "guest_#{"0" * 11}@example.com")
        guest_user.valid?
        expect(guest_user.errors[:email]).to include("has already been taken")
      end

      it "is a valid email for a guest user that composed of guest_ + [11-digit number] + @example.com" do
        guest_user = FactoryBot.build(:guest_user, email: "guest_#{"0" * 11}@example.com")
        expect(guest_user).to be_valid
      end

      it "is a valid email for a guest user that composed of guest_ + [12-digit number] + @example.com" do
        guest_user = FactoryBot.build(:guest_user, email: "guest_#{"9" * 12}@example.com")
        expect(guest_user).to be_valid
      end

      it "is an invalid email for a guest user that composed of guest_ + [10-digit number] + @example.com" do
        guest_user = FactoryBot.build(:guest_user, email: "guest_#{"9" * 10}@example.com")
        guest_user.valid?
        expect(guest_user.errors[:email]).to include("invalid email format for a guest user")
      end

      it "is an invalid email for a guest user that composed of guest_ + [13-digit number] + @example.com" do
        guest_user = FactoryBot.build(:guest_user, email: "guest_#{"0" * 13}@example.com")
        guest_user.valid?
        expect(guest_user.errors[:email]).to include("invalid email format for a guest user")
      end
    end

    context "as a sign-in user" do
      it "is a valid email with normalization" do
        sign_in_user = FactoryBot.build(:sign_in_user, email: " \t\r\n\f\v\0EXAMPLE@EXAMPLE.COM \t\r\n\f\v\0")
        expect(sign_in_user.email).to eq "example@example.com"
      end

      it "is invalid without an email" do
        sign_in_user = FactoryBot.build(:sign_in_user, email: nil)
        sign_in_user.valid?
        expect(sign_in_user.errors[:email]).to include("can't be blank")
      end

      it "is invalid with a duplicated email" do
        FactoryBot.create(:sign_in_user, email: "example@example.com")
        sign_in_user = FactoryBot.build(:sign_in_user, email: "example@example.com")
        sign_in_user.valid?
        expect(sign_in_user.errors[:email]).to include("has already been taken")
      end

      it "is a valid email for a sign-in user that the length is less than 255 characters" do
        sign_in_user = FactoryBot.build(:sign_in_user)
        expect(sign_in_user).to be_valid
      end

      it "is a valid email for a sign-in user that the length is equal to 255 characters" do
        sign_in_user = FactoryBot.build(:sign_in_user, email: "#{SecureRandom.alphanumeric(243).downcase}@example.com")
        expect(sign_in_user).to be_valid
      end

      it "is a valid email for a sign-in user that the length is greater than 255 characters" do
        sign_in_user = FactoryBot.build(:sign_in_user, email: "#{SecureRandom.alphanumeric(244).downcase}@example.com")
        sign_in_user.valid?
        expect(sign_in_user.errors[:email]).to include("email must be less than or equal to 255 characters")
      end

      it "is an invalid email for a sign-in user that composed of guest_ + [11-digit number] + @example.com" do
        sign_in_user = FactoryBot.build(:sign_in_user, email: "guest_#{"0" * 11}@example.com")
        sign_in_user.valid?
        expect(sign_in_user.errors[:email]).to include("invalid email format for a sign-in user")
      end

      it "is an invalid email for a sign-in user that composed of guest_ + [12-digit number] + @example.com" do
        sign_in_user = FactoryBot.build(:sign_in_user, email: "guest_#{"9" * 12}@example.com")
        sign_in_user.valid?
        expect(sign_in_user.errors[:email]).to include("invalid email format for a sign-in user")
      end

      it "is a valid email for a sign-in user that composed of guest_ + [10-digit number] + @example.com" do
        sign_in_user = FactoryBot.build(:sign_in_user, email: "guest_#{"9" * 10}@example.com")
        expect(sign_in_user).to be_valid
      end

      it "is a valid email for a sign-in user that composed of guest_ + [13-digit number] + @example.com" do
        sign_in_user = FactoryBot.build(:sign_in_user, email: "guest_#{"0" * 13}@example.com")
        expect(sign_in_user).to be_valid
      end
    end
  end

  describe "validate a total tasks count" do
    context "as a guest user" do
      it "is invald without a total tasks count" do
        guest_user = FactoryBot.build(:guest_user, total_tasks_count: nil)
        guest_user.valid?
        expect(guest_user.errors[:total_tasks_count]).to include("can't be blank")
      end

      it "is invalid that a total tasks count is minus" do
        guest_user = FactoryBot.build(:guest_user, total_tasks_count: -1)
        guest_user.valid?
        expect(guest_user.errors[:total_tasks_count]).to include("must be in 0..255")
      end

      it "is valid that a total tasks count is 0" do
        guest_user = FactoryBot.build(:guest_user, total_tasks_count: 0, done_tasks_count: 0, working_task_order: 0)
        expect(guest_user).to be_valid
      end

      it "is valid that a total tasks count is 255" do
        guest_user = FactoryBot.build(:guest_user, total_tasks_count: 255)
        expect(guest_user).to be_valid
      end

      it "is invalid that a total tasks count is 256" do
        guest_user = FactoryBot.build(:guest_user, total_tasks_count: 256)
        guest_user.valid?
        expect(guest_user.errors[:total_tasks_count]).to include("must be in 0..255")
      end

      it "is invalid that a total tasks count is float" do
        guest_user = FactoryBot.build(:guest_user, total_tasks_count: 0.5)
        guest_user.valid?
        expect(guest_user.errors[:total_tasks_count]).to include("must be an integer")
      end

      it "is invalid that a total tasks count is character" do
        guest_user = FactoryBot.build(:guest_user, total_tasks_count: " ")
        guest_user.valid?
        expect(guest_user.errors[:total_tasks_count]).to include("can't be blank", "is not a number")
      end
    end

    context "as a sign-in user" do
      it "is invald without a total tasks count" do
        sign_in_user = FactoryBot.build(:sign_in_user, total_tasks_count: nil)
        sign_in_user.valid?
        expect(sign_in_user.errors[:total_tasks_count]).to include("can't be blank")
      end

      it "is invalid that a total tasks count is minus" do
        sign_in_user = FactoryBot.build(:sign_in_user, total_tasks_count: -1)
        sign_in_user.valid?
        expect(sign_in_user.errors[:total_tasks_count]).to include("must be in 0..255")
      end

      it "is valid that a total tasks count is 0" do
        sign_in_user = FactoryBot.build(:sign_in_user, total_tasks_count: 0, done_tasks_count: 0, working_task_order: 0)
        expect(sign_in_user).to be_valid
      end

      it "is valid that a total tasks count is 255" do
        sign_in_user = FactoryBot.build(:sign_in_user, total_tasks_count: 255)
        expect(sign_in_user).to be_valid
      end

      it "is invalid that a total tasks count is 256" do
        sign_in_user = FactoryBot.build(:sign_in_user, total_tasks_count: 256)
        sign_in_user.valid?
        expect(sign_in_user.errors[:total_tasks_count]).to include("must be in 0..255")
      end

      it "is invalid that a total tasks count is float" do
        sign_in_user = FactoryBot.build(:sign_in_user, total_tasks_count: 0.5)
        sign_in_user.valid?
        expect(sign_in_user.errors[:total_tasks_count]).to include("must be an integer")
      end

      it "is invalid that a total tasks count is character" do
        sign_in_user = FactoryBot.build(:sign_in_user, total_tasks_count: " ")
        sign_in_user.valid?
        expect(sign_in_user.errors[:total_tasks_count]).to include("can't be blank", "is not a number")
      end
    end
  end

  describe "validate a done tasks count" do
    context "as a guest user" do
      it "is invald without a done tasks count" do
        guest_user = FactoryBot.build(:guest_user, done_tasks_count: nil)
        guest_user.valid?
        expect(guest_user.errors[:done_tasks_count]).to include("can't be blank")
      end

      it "is invalid that a done tasks count is minus" do
        guest_user = FactoryBot.build(:guest_user, done_tasks_count: -1)
        guest_user.valid?
        expect(guest_user.errors[:done_tasks_count]).to include("must be in 0..255")
      end

      it "is valid that a done tasks count is 0" do
        guest_user = FactoryBot.build(:guest_user, done_tasks_count: 0)
        expect(guest_user).to be_valid
      end

      it "is valid that a done tasks count is 255" do
        guest_user = FactoryBot.build(:guest_user, total_tasks_count: 255, done_tasks_count: 255, working_task_order: 0)
        expect(guest_user).to be_valid
      end

      it "is invalid that a done tasks count is 256" do
        guest_user = FactoryBot.build(:guest_user, done_tasks_count: 256)
        guest_user.valid?
        expect(guest_user.errors[:done_tasks_count]).to include("must be in 0..255")
      end

      it "is invalid that a done tasks count is float" do
        guest_user = FactoryBot.build(:guest_user, done_tasks_count: 0.5)
        guest_user.valid?
        expect(guest_user.errors[:done_tasks_count]).to include("must be an integer")
      end

      it "is invalid that a done tasks count is character" do
        guest_user = FactoryBot.build(:guest_user, done_tasks_count: " ")
        guest_user.valid?
        expect(guest_user.errors[:done_tasks_count]).to include("can't be blank", "is not a number")
      end

      it "is valid that a done tasks count is less than a total tasks count" do
        total_tasks_count = rand(1..255)
        done_tasks_count = rand(0..(total_tasks_count - 1))
        working_task_order = rand(0..total_tasks_count)
        guest_user = FactoryBot.build(
          :guest_user, total_tasks_count: total_tasks_count, done_tasks_count: done_tasks_count, working_task_order: working_task_order)
        expect(guest_user).to be_valid
      end

      it "is valid that a done tasks count is equal to a total tasks count" do
        total_tasks_count = rand(1..255)
        done_tasks_count = total_tasks_count
        guest_user = FactoryBot.build(
          :guest_user, total_tasks_count: total_tasks_count, done_tasks_count: done_tasks_count, working_task_order: 0)
        expect(guest_user).to be_valid
      end

      it "is invalid that a done tasks count is greater than a total tasks count" do
        done_tasks_count = rand(1..255)
        total_tasks_count = rand(0..(done_tasks_count - 1))
        guest_user = FactoryBot.build(
          :guest_user, total_tasks_count: total_tasks_count, done_tasks_count: done_tasks_count)
        guest_user.valid?
        expect(guest_user.errors[:done_tasks_count]).to include("must be less than or equal to #{total_tasks_count}")
      end
    end

    context "as a sign-in user" do
      it "is invald without a done tasks count" do
        sign_in_user = FactoryBot.build(:sign_in_user, done_tasks_count: nil)
        sign_in_user.valid?
        expect(sign_in_user.errors[:done_tasks_count]).to include("can't be blank")
      end

      it "is invalid that a done tasks count is minus" do
        sign_in_user = FactoryBot.build(:sign_in_user, done_tasks_count: -1)
        sign_in_user.valid?
        expect(sign_in_user.errors[:done_tasks_count]).to include("must be in 0..255")
      end

      it "is valid that a done tasks count is 0" do
        sign_in_user = FactoryBot.build(:sign_in_user, done_tasks_count: 0)
        expect(sign_in_user).to be_valid
      end

      it "is valid that a done tasks count is 255" do
        sign_in_user = FactoryBot.build(:sign_in_user, total_tasks_count: 255, done_tasks_count: 255, working_task_order: 0)
        expect(sign_in_user).to be_valid
      end

      it "is invalid that a done tasks count is 256" do
        sign_in_user = FactoryBot.build(:sign_in_user, done_tasks_count: 256)
        sign_in_user.valid?
        expect(sign_in_user.errors[:done_tasks_count]).to include("must be in 0..255")
      end

      it "is invalid that a done tasks count is float" do
        sign_in_user = FactoryBot.build(:sign_in_user, done_tasks_count: 0.5)
        sign_in_user.valid?
        expect(sign_in_user.errors[:done_tasks_count]).to include("must be an integer")
      end

      it "is invalid that a done tasks count is character" do
        sign_in_user = FactoryBot.build(:sign_in_user, done_tasks_count: " ")
        sign_in_user.valid?
        expect(sign_in_user.errors[:done_tasks_count]).to include("can't be blank", "is not a number")
      end

      it "is valid that a done tasks count is less than a total tasks count" do
        total_tasks_count = rand(1..255)
        done_tasks_count = rand(0..(total_tasks_count - 1))
        working_task_order = rand(0..total_tasks_count)
        sign_in_user = FactoryBot.build(
          :sign_in_user, total_tasks_count: total_tasks_count, done_tasks_count: done_tasks_count, working_task_order: working_task_order)
        expect(sign_in_user).to be_valid
      end

      it "is valid that a done tasks count is equal to a total tasks count" do
        total_tasks_count = rand(1..255)
        done_tasks_count = total_tasks_count
        sign_in_user = FactoryBot.build(
          :sign_in_user, total_tasks_count: total_tasks_count, done_tasks_count: done_tasks_count, working_task_order: 0)
        expect(sign_in_user).to be_valid
      end

      it "is invalid that a done tasks count is greater than a total tasks count" do
        done_tasks_count = rand(1..255)
        total_tasks_count = rand(0..(done_tasks_count - 1))
        sign_in_user = FactoryBot.build(
          :sign_in_user, total_tasks_count: total_tasks_count, done_tasks_count: done_tasks_count)
        sign_in_user.valid?
        expect(sign_in_user.errors[:done_tasks_count]).to include("must be less than or equal to #{total_tasks_count}")
      end
    end
  end

  describe "validate a working task order" do
    context "as a guest user" do
      it "is invald without a working task order" do
        guest_user = FactoryBot.build(:guest_user, working_task_order: nil)
        guest_user.valid?
        expect(guest_user.errors[:working_task_order]).to include("can't be blank")
      end

      it "is invalid that a working task order is minus" do
        guest_user = FactoryBot.build(:guest_user, working_task_order: -1)
        guest_user.valid?
        expect(guest_user.errors[:working_task_order]).to include("must be in 0..255")
      end

      it "is valid that a working task order is 0" do
        guest_user = FactoryBot.build(:guest_user, working_task_order: 0)
        expect(guest_user).to be_valid
      end

      it "is valid that a working task order is 255" do
        guest_user = FactoryBot.build(:guest_user, total_tasks_count: 255, working_task_order: 255)
        expect(guest_user).to be_valid
      end

      it "is invalid that a working task order is 256" do
        guest_user = FactoryBot.build(:guest_user, working_task_order: 256)
        guest_user.valid?
        expect(guest_user.errors[:working_task_order]).to include("must be in 0..255")
      end

      it "is invalid that a working task order is float" do
        guest_user = FactoryBot.build(:guest_user, working_task_order: 0.5)
        guest_user.valid?
        expect(guest_user.errors[:working_task_order]).to include("must be an integer")
      end

      it "is invalid that a working task order is character" do
        guest_user = FactoryBot.build(:guest_user, working_task_order: " ")
        guest_user.valid?
        expect(guest_user.errors[:working_task_order]).to include("can't be blank", "is not a number")
      end

      it "is valid that a working task order is less than a total tasks count" do
        total_tasks_count = rand(1..255)
        done_tasks_count = rand(0..(total_tasks_count - 1))
        working_task_order = rand(0..(total_tasks_count - 1))
        guest_user = FactoryBot.build(
          :guest_user, total_tasks_count: total_tasks_count, done_tasks_count: done_tasks_count, working_task_order: working_task_order)
        expect(guest_user).to be_valid
      end

      it "is valid that a working task order is equal to a total tasks count" do
        total_tasks_count = rand(1..255)
        done_tasks_count = rand(0..(total_tasks_count - 1))
        working_task_order = total_tasks_count
        guest_user = FactoryBot.build(
          :guest_user, total_tasks_count: total_tasks_count, done_tasks_count: done_tasks_count, working_task_order: working_task_order)
        expect(guest_user).to be_valid
      end

      it "is invalid that a working task order is greater than a total tasks count" do
        working_task_order = rand(1..255)
        total_tasks_count = rand(0..(working_task_order - 1))
        guest_user = FactoryBot.build(
          :guest_user, total_tasks_count: total_tasks_count, working_task_order: working_task_order)
        guest_user.valid?
        expect(guest_user.errors[:working_task_order]).to include("must be less than or equal to #{total_tasks_count}")
      end
    end

    context "as a sign-in user" do
      it "is invald without a working task order" do
        sign_in_user = FactoryBot.build(:sign_in_user, working_task_order: nil)
        sign_in_user.valid?
        expect(sign_in_user.errors[:working_task_order]).to include("can't be blank")
      end

      it "is invalid that a working task order is minus" do
        sign_in_user = FactoryBot.build(:sign_in_user, working_task_order: -1)
        sign_in_user.valid?
        expect(sign_in_user.errors[:working_task_order]).to include("must be in 0..255")
      end

      it "is valid that a working task order is 0" do
        sign_in_user = FactoryBot.build(:sign_in_user, working_task_order: 0)
        expect(sign_in_user).to be_valid
      end

      it "is valid that a working task order is 255" do
        sign_in_user = FactoryBot.build(:sign_in_user, total_tasks_count: 255, working_task_order: 255)
        expect(sign_in_user).to be_valid
      end

      it "is invalid that a working task order is 256" do
        sign_in_user = FactoryBot.build(:sign_in_user, working_task_order: 256)
        sign_in_user.valid?
        expect(sign_in_user.errors[:working_task_order]).to include("must be in 0..255")
      end

      it "is invalid that a working task order is float" do
        sign_in_user = FactoryBot.build(:sign_in_user, working_task_order: 0.5)
        sign_in_user.valid?
        expect(sign_in_user.errors[:working_task_order]).to include("must be an integer")
      end

      it "is invalid that a working task order is character" do
        sign_in_user = FactoryBot.build(:sign_in_user, working_task_order: " ")
        sign_in_user.valid?
        expect(sign_in_user.errors[:working_task_order]).to include("can't be blank", "is not a number")
      end

      it "is valid that a working task order is less than a total tasks count" do
        total_tasks_count = rand(1..255)
        done_tasks_count = rand(0..(total_tasks_count - 1))
        working_task_order = rand(0..(total_tasks_count - 1))
        sign_in_user = FactoryBot.build(
          :sign_in_user, total_tasks_count: total_tasks_count, done_tasks_count: done_tasks_count, working_task_order: working_task_order)
        expect(sign_in_user).to be_valid
      end

      it "is valid that a working task order is equal to a total tasks count" do
        total_tasks_count = rand(1..255)
        done_tasks_count = rand(0..(total_tasks_count - 1))
        working_task_order = total_tasks_count
        sign_in_user = FactoryBot.build(
          :sign_in_user, total_tasks_count: total_tasks_count, done_tasks_count: done_tasks_count, working_task_order: working_task_order)
        expect(sign_in_user).to be_valid
      end

      it "is invalid that a working task order is greater than a total tasks count" do
        working_task_order = rand(1..255)
        total_tasks_count = rand(0..(working_task_order - 1))
        sign_in_user = FactoryBot.build(
          :sign_in_user, total_tasks_count: total_tasks_count, working_task_order: working_task_order)
        sign_in_user.valid?
        expect(sign_in_user.errors[:working_task_order]).to include("must be less than or equal to #{total_tasks_count}")
      end
    end
  end
end
