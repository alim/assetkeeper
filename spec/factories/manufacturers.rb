# Manufacturer  -------------------------------------------------

FactoryGirl.define do
  factory :manufacturer do
    name "Herman Munster"
    address "1313 MockingBird Lane"
    website "www.oldtvshow.com"
    main_phone "888-999-0000"
    main_fax "888-999-1111"
    tags "Comedy"
  end

  # Manufacturer with Embedded Contact -------------------------------------------------

  factory :manufacturercontact, class: Manufacturer do
    name "Minnie Mouse"
    address "4600 World Drive, Orlando, FL 32830"
    website "www.cartoons.com"
    main_phone "888-999-0000"
    main_fax "888-999-1111"
    tags "Disney"

    contacts {[
      FactoryGirl.build(:contact),
      FactoryGirl.build(:contact)
    ]}
  end
end
