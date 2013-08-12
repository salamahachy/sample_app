FactoryGirl.define do
  factory :user do
    name     "Test User"
    email    "test@test.de"
    password "qwertz"
    password_confirmation "qwertz"
  end
end