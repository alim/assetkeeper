require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe ContactsController, :type => :controller do

  include_context 'contact_setup'
  include_context 'user_setup'

# CREATE A LIST OF MANUFACTURERS -------------------------------------------

  let(:find_a_contact) {
    create_contacts
    @fake_contact = Contact.last
  }

  # CREATE PARAMETERS -------------------------------------------

  let(:create_params) {
      {contact:
        {
         name: @fake_contact.name,
         email: @fake_contact.email,
         phone: @fake_contact.phone,
         body: @fake_contact.body,
        }
      }
    }

# LOGIN AS ADMIN -------------------------------------------

  let(:login_contact_admin) {
   @contact_admin_user = FactoryGirl.create(:adminuser)
   sign_in @contact_admin_user
  }

# LOGIN AS NON-ADMIN -------------------------------------------

  let(:login_non_contact_admin) {
   sign_out subject.current_user
   @non_contact_admin_user = FactoryGirl.create(:user)
   sign_in @non_manufacturer_admin_user
  }

# LOG BACK IN AS ADMIN -------------------------------------------

  let(:log_back_in_contact_admin) {
   sign_out subject.current_user
   sign_in @contact_admin_user
  }

  # INITIALIZE PARAMETERS -------------------------------------------

  let(:show_params) { {id: @fake_manufacturer } }
  let(:edit_params) { {id: @fake_manufacturer } }
  let(:destroy_params){ {id: @fake_manufacturer } }

  let(:new_main_phone){ "999-999-9999" }
  let(:update_params){
    {
     id: @fake_contact,
      manufacturer: {
      phone: new_phone,
     }
    }
   }

   # SETUP FOR EACH ADMIN TEST -------------------------------------------

    before(:each) {
     find_a_contact
     login_contact_admin
    }

    after(:each) {
     Contact.destroy_all
    }

    # ADMIN TESTS -------------------------------------------

end
