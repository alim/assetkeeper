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
    condition Asset::CONDITION_VALUES[:good]
    failure_probablity Asset::FAILURE_VALUES[:neither]
    failure_consequence Asset::CONSEQUENCE_VALUES[:moderate]
    status Asset::STATUS_VALUES[:operational]
  end

end
