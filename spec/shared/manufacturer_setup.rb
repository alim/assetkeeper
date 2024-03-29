########################################################################
# Provide shared macros for testing manufacturer
########################################################################
shared_context 'manufacturer_setup' do

  # Manufacturer setup -------------------------------------------------
  let(:create_manufacturers) {
    5.times.each { FactoryGirl.create(:manufacturer) }
  }

  let(:create_one_manufacturer) {
    1.times.each { FactoryGirl.create(:manufacturer) }
  }

  # Manufacturer setup with Embedded Contact -------------------------------------------------

  let(:create_manufacturers_with_contact) {
    5.times.each { FactoryGirl.create(:manufacturercontact) }
  }
end
