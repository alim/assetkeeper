FactoryGirl.define do
  sequence :name do |n|
    "Water Pipe#{n}"
  end

  factory :asset do
    name { generate(:name) }
    description "Just some pipe"
    location "Some location"
    latitude "44.122"
    longitude "45.321"
    material "MyString"
    date_installed Date.new(2014, 12, 1)
    condition Asset::GOOD_CONDITION
    failure_probablity Asset::NEITHER_FAILURE
    failure_consequence Asset::EXTREMELY_HIGH_CONSEQUENCE
    status Asset::OPERATIONAL
  end

end
