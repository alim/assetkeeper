########################################################################
# Provide shared macros for testing user accounts
########################################################################
shared_context 'manufacturer_setup' do

  # Manufacturer setup -------------------------------------------------
  let(:create_manufacturers) {
    5.times.each { FactoryGirl.create(:manufacturer) }
  }

end
