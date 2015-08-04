include ActionDispatch::TestProcess

FactoryGirl.define do
  sequence :photo_name do |n|
    "Photo-#{n}"
  end

  factory :photo do
    name { generate(:photo_name) }
    description "Just a test photo description"
    lat "42.4533308"
    long "-83.9437406"

    # The fixture_file_upload is from the ActionDispatch::TestProcess
    # module.
    image { fixture_file_upload(Rails.root.join('spec/fixtures/test_photo_large.jpg'),
     'image/png') }
  end
end
