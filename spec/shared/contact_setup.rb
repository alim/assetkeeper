###########################################################################
# Provide shared macros for testing manufacturer contacts
###########################################################################
shared_context 'contact_setup' do

  # Manufacturer Contact setup -------------------------------------------------
  let(:create_contacts) {
    5.times.each { FactoryGirl.create(:contact) }
  }
end
