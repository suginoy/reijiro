FactoryGirl.define do
  factory :clip do
    status 0
    association :word, factory: :word
  end
end
