require 'spec_helper'

describe Manufacturer, :type => :model do
  include_context 'manufacturer_setup'
  include_context 'user_setup'

 # CREATE A LIST OF MANUFACTURERS ------------------------------------------------

 let(:find_a_manufacturer) {
    create_manufacturers
    @manufacturer = Manufacturer.last
  }

  # CREATE A LIST OF MANUFACTURERS WITH CONTACTS ------------------------------------------------

 let(:find_a_manufacturer_with_contact) {
    create_manufacturers_with_contact
    @manufacturer_with_contact = Manufacturer.last
  }

 # LOGIN AS ADMIN  ------------------------------------------------

  let(:admin_login) {
   @login = FactoryGirl.create(:adminuser)
  }

 # SETUP FOR EACH TEST  ------------------------------------------------

  before(:each) {
   find_a_manufacturer
  }

  after(:each) {
   Manufacturer.destroy_all
  }

 ## METHOD CHECKS -----------------------------------------------------
    describe "Should respond to all accessor methods" do
                it { is_expected.to respond_to(:name) }
                it { is_expected.to respond_to(:address) }
                it { is_expected.to respond_to(:website) }
                it { is_expected.to respond_to(:main_phone) }
                it { is_expected.to respond_to(:main_fax) }
                it { is_expected.to respond_to(:tags) }
     end

# VALIDATION TESTS ---------------------------------------------------
  describe "Validation tests" do

    it "With all fields, model should be valid" do
      manu = FactoryGirl.create(:manufacturer)
      expect(manu).to be_valid
    end

    it "Should not be valid, if name is missing" do
      @manufacturer.name = nil
      expect(@manufacturer).not_to be_valid
    end

    it "Should not be valid, if address is missing" do
      @manufacturer.address = nil
      expect(@manufacturer).not_to be_valid
    end

    it "Should not be valid, if website is missing" do
      @manufacturer.website = nil
      expect(@manufacturer).not_to be_valid
    end

    it "Should not be valid, if main phone is missing" do
      @manufacturer.main_phone = nil
      expect(@manufacturer).not_to be_valid
    end

    it "Should not be valid, if main fax is missing" do
      @manufacturer.main_fax = nil
      expect(@manufacturer).not_to be_valid
    end

    it "Should not be valid, if tags is missing" do
      @manufacturer.tags = nil
      expect(@manufacturer).not_to be_valid
    end
 end

# INITIALIZE PARAMETERS ---------------------------------------------------
  let(:set_params) {
   @manufacturer_params = {
     name: "ACME",
     address: "1313 MockingBird Lane",
     website: "www.acme.com",
     main_phone: "123-456-7890",
     main_fax: "098-567-1234",
     tags: "None"
   }
  }

# CREATE ADMIN USER ---------------------------------------------------
  let(:manufacturer_admin) {
   @manufacturer_admin_user = FactoryGirl.create(:adminuser)
  }

# CREATE NON-ADMIN USER ---------------------------------------------------
  let(:non_manufacturer_admin) {
   @non_manufacturer_admin_user = FactoryGirl.create(:user)
  }

 # SETUP FOR EACH TEST  ------------------------------------------------

  before(:each) {
   find_a_manufacturer
   manufacturer_admin
   non_manufacturer_admin
   set_params
  }

  after(:each) {
   Manufacturer.destroy_all
  }

  # CREATE MANUFACTURER TEST ------------------------------------

 describe "Create manufacturer examples", :vcr do
      it "should return manufacturer object when created by admin" do
        expect {
          Manufacturer.create_with_user(@manufacturer_params,
             @manufacturer_admin_user).save
        }.to_not raise_error
      end

      it "should not return manufacturer object when created by user" do
        expect {
          Manufacturer.create_with_user(@manufacturer_params,
             @non_manufacturer_admin_user).save
        }.to raise_error
      end

      it "should create a new manufacturer when created by admin" do
      expect {
        Manufacturer.create_with_user(@manufacturer_params, @manufacturer_admin_user).save
      }.to change(Manufacturer, :count).by(1)
    end
 end


  # Nested / embedded Contact Tests ------------------------------------

  describe "Nested/embedded Contact Tests" do
    before(:each) {
      @manufacturer_with_contacts = FactoryGirl.create(:manufacturercontact)
      @contacts = @manufacturer_with_contacts.contacts.last
    }

    describe "Valid tests" do
      it "Should be valid to have an embedded contact" do
        expect(@manufacturer_with_contacts).to be_valid
      end

      it "Should have a contact name" do
        expect(@contacts.name).to be_present
      end

      it "Should have a contact email" do
        expect(@contacts.email).to be_present
      end

      it "Should have a contact phone" do
        expect(@contacts.phone).to be_present
      end

      it "Should have a contact body" do
        expect(@contacts.body).to be_present
      end

      it "Should have a contact phone" do
        expect(@contacts.phone).to eq("734.555.1212")
      end
    end
  end
end
