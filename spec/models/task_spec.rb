require 'rails_helper'

RSpec.describe Task, type: :model do
  describe "create a task" do
    it "has a valid factory" do
      expect(FactoryBot.build(:task)).to be_valid
    end

    it "is valid with a task name and a task time" do
      (1..255).each do |n|
        task = FactoryBot.build(:task, task_order: n, task_name: "#{SecureRandom.alphanumeric(n)}")
        expect(task).to be_valid
      end
    end
  end

  describe "validate a task order" do
    it "is invalid without a task order" do
      task = FactoryBot.build(:task, task_order: nil)
      task.valid?
      expect(task.errors[:task_order]).to include("can't be blank")
    end

    it "is invalid that a task order is 0" do
      task = FactoryBot.build(:task, task_order: 0)
      task.valid?
      expect(task.errors[:task_order]).to include("must be in 1..255")
    end

    it "is valid that a task order is 1" do
      task = FactoryBot.build(:task, task_order: 1)
      expect(task).to be_valid
    end

    it "is valid that a task order is 255" do
      task = FactoryBot.build(:task, task_order: 255)
      expect(task).to be_valid
    end

    it "is invalid that a task order is 256" do
      task = FactoryBot.build(:task, task_order: 256)
      task.valid?
      expect(task.errors[:task_order]).to include("must be in 1..255")
    end

    it "is invalid that a task order is float" do
      task = FactoryBot.build(:task, task_order: 1.5)
      task.valid?
      expect(task.errors[:task_order]).to include("must be an integer")
    end

    it "is invalid that a task order is character" do
      task = FactoryBot.build(:task, task_order: " ")
      task.valid?
      expect(task.errors[:task_order]).to include("can't be blank", "is not a number")
    end
  end

  describe "validate a task name" do
    it "is invalid without a task name" do
      task = FactoryBot.build(:task, task_name: nil)
      task.valid?
      expect(task.errors[:task_name]).to include("can't be blank")
    end

    it "is valid that task a name consists of 1 character" do
      task = FactoryBot.build(:task, task_name: "#{SecureRandom.alphanumeric(1)}")
      expect(task).to be_valid
    end

    it "is invalid that a task name consists of blank" do
      task = FactoryBot.build(:task, task_name: " " * rand(1..255))
      task.valid?
      expect(task.errors[:task_name]).to include("can't be blank")
    end

    it "is valid that a task name consists of 255 characters" do
      task = FactoryBot.build(:task, task_name: "#{SecureRandom.alphanumeric(255)}")
      expect(task).to be_valid
    end

    it "is invalid that a task name consists of 256 characters" do
      task = FactoryBot.build(:task, task_name: "#{SecureRandom.alphanumeric(256)}")
      task.valid?
      expect(task.errors[:task_name]).to include("is too long (maximum is 255 characters)")
    end
  end

  describe "validate a task time" do
    it "is invalid without a task time" do
      task = FactoryBot.build(:task, task_time: nil)
      task.valid?
      expect(task.errors[:task_time]).to include("can't be blank")
    end

    it "is invalid that task time is 0 sec" do
      task = FactoryBot.build(:task, task_time: 0)
      task.valid?
      expect(task.errors[:task_time]).to include("must be in 1..86400")
    end

    it "is valid that task time is 1 sec" do
      task = FactoryBot.build(:task, task_time: 1)
      expect(task).to be_valid
    end

    it "is valid that task time is 24 * 60 * 60 sec (86400 sec, 1 day)" do
      task = FactoryBot.build(:task, task_time: 24 * 60 * 60)
      expect(task).to be_valid
    end

    it "is invalid task time with 24 * 60 * 60 sec + 1 min (86401 sec, 1 day + 1 sec)" do
      task = FactoryBot.build(:task, task_time: 24 * 60 * 60 + 1)
      task.valid?
      expect(task.errors[:task_time]).to include("must be in 1..86400")
    end

    it "is invalid that task time is float" do
      task = FactoryBot.build(:task, task_time: 1.5)
      task.valid?
      expect(task.errors[:task_time]).to include("must be an integer")
    end

    it "is invalid that task time is character" do
      task = FactoryBot.build(:task, task_time: " ")
      task.valid?
      expect(task.errors[:task_time]).to include("can't be blank", "is not a number")
    end
  end

  describe "validate a done flag" do
    it "is invalid without done flag" do
      task = FactoryBot.build(:task, done_flag: nil)
      task.valid?
      expect(task.errors[:done_flag]).to include("is not included in the list")
    end

    it "is valid that done flag is true" do
      task = FactoryBot.build(:task, done_flag: true)
      expect(task).to be_valid
    end

    it "is valid that done flag is false" do
      task = FactoryBot.build(:task, done_flag: false)
      expect(task).to be_valid
    end
  end

  describe "validate a timer flag" do
    it "is invalid without timer flag" do
      task = FactoryBot.build(:task, timer_flag: nil)
      task.valid?
      expect(task.errors[:timer_flag]).to include("is not included in the list")
    end

    it "is valid that timer flag is true" do
      task = FactoryBot.build(:task, timer_flag: true)
      expect(task).to be_valid
    end

    it "is valid that timer flag is false" do
      task = FactoryBot.build(:task, timer_flag: false)
      expect(task).to be_valid
    end
  end

  describe "validate a timer started at" do
    it "is invalid without a timer started at" do
      task = FactoryBot.build(:task, timer_started_at: nil)
      task.valid?
      expect(task.errors[:timer_started_at]).to include("can't be blank")
    end

    it "is valid that a timer started at is an instance of time class" do
      task = FactoryBot.build(:task, timer_started_at: Time.now)
      expect(task).to be_valid
    end

    it "is invalid that a timer started at is an integer" do
      task = FactoryBot.build(:task, timer_started_at: 0)
      task.valid?
      expect(task.errors[:timer_started_at]).to include("must be an instance of time class")
    end
  end

  describe "validate a timer stopped at" do
    it "is invalid without a timer stopped at" do
      task = FactoryBot.build(:task, timer_stopped_at: nil)
      task.valid?
      expect(task.errors[:timer_stopped_at]).to include("can't be blank")
    end

    it "is valid that a timer stopped at is an instance of time class" do
      task = FactoryBot.build(:task, timer_stopped_at: Time.now)
      expect(task).to be_valid
    end

    it "is invalid that a timer started at is an integer" do
      task = FactoryBot.build(:task, timer_stopped_at: 0)
      task.valid?
      expect(task.errors[:timer_stopped_at]).to include("must be an instance of time class")
    end
  end

  describe "validate a elapsed task time" do
    it "is invalid without a elapsed task time" do
      task = FactoryBot.build(:task, elapsed_task_time: nil)
      task.valid?
      expect(task.errors[:elapsed_task_time]).to include("can't be blank")
    end

    it "is invalid that a elapsed task time is minus" do
      task = FactoryBot.build(:task, elapsed_task_time: -1)
      task.valid?
      expect(task.errors[:elapsed_task_time]).to include("must be in 0..")
    end

    it "is valid that a elapsed task time is 0" do
      task = FactoryBot.build(:task, elapsed_task_time: 0)
      expect(task).to be_valid
    end

    it "is valid that a elapsed task time is greater than 0" do
      task = FactoryBot.build(:task, elapsed_task_time: rand(1..(24 * 60 * 60)))
      expect(task).to be_valid
    end

    it "is invalid that a elapsed task time is float" do
      task = FactoryBot.build(:task, elapsed_task_time: 0.5)
      task.valid?
      expect(task.errors[:elapsed_task_time]).to include("must be an integer")
    end

    it "is invalid that a elapsed task time is character" do
      task = FactoryBot.build(:task, elapsed_task_time: " ")
      task.valid?
      expect(task.errors[:elapsed_task_time]).to include("can't be blank", "is not a number")
    end
  end
end
