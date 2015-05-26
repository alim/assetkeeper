FactoryGirl.define do
  sequence :name do |n|
    "Water Pipe#{n}"
  end

  factory :asset_item do
    name { generate(:name) }
    description "Just some pipe"
    location "Some location"
    latitude "42.4533308"
    longitude "-83.9437406"
    material "MyString"
    date_installed Date.new(2014, 12, 1)
    condition AssetItem::CONDITION_VALUES[:good]
    failure_probability AssetItem::FAILURE_VALUES[:neither]
    failure_consequence AssetItem::CONSEQUENCE_VALUES[:moderate]
    status AssetItem::STATUS_VALUES[:operational]
    tags "Steel, Round"
  end
end
