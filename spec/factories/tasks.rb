FactoryBot.define do
  factory :task do
    task_order { rand(1..255) }
    task_name { "#{SecureRandom.alphanumeric(rand(1..255))}" }
    task_time { rand(1..(24 * 60)) }
    done_flag { false }
    timer_flag { false }
    timer_started_at { Time.now }
    timer_stopped_at { Time.now }
    elapsed_task_time { rand(0..(24 * 60 * 60)) }
    association :user
  end
end
