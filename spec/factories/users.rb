FactoryBot.define do
  total_tasks_count = rand(0..255)
  done_tasks_count = rand(0..total_tasks_count)
  working_task_order = rand(0..total_tasks_count)

  factory :user, aliases: [ :guest_user ] do
    guest { true }
    email { "guest_#{Time.now.to_i}#{rand(100)}@example.com" }
    password { "example" }
    total_tasks_count { total_tasks_count }
    done_tasks_count { done_tasks_count }
    working_task_order { working_task_order }

    factory :sign_in_user do
      guest { false }
      email { "#{SecureRandom.alphanumeric(rand(1..243)).downcase}@example.com" }
    end
  end
end
