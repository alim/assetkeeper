require 'spec_helper'

RSpec.describe ManufacturersController, type: :controller do
  include_context 'manufacturer_setup'
  include_context 'user_setup'

  # CREATE A LIST OF MANUFACTURERS -------------------------------------------

  let(:find_a_manufacturer) do
    create_manufacturers
    @fake_manufacturer = Manufacturer.last
  end

  # CREATE PARAMETERS -------------------------------------------

  let(:create_params) do
    { manufacturer:
      {
        name: @fake_manufacturer.name,
        address: @fake_manufacturer.address,
        website: @fake_manufacturer.website,
        main_phone: @fake_manufacturer.main_phone,
        main_fax: @fake_manufacturer.main_fax,
        tags: @fake_manufacturer.tags
      }
    }
  end

  # LOGIN AS ADMIN -----------------------------------------------

  let(:login_manufacturer_admin) do
    @manufacturer_admin_user = FactoryGirl.create(:adminuser)
    sign_in @manufacturer_admin_user
  end

  # LOGIN AS NON-ADMIN -------------------------------------------

  let(:login_non_manufacturer_admin) do
    sign_out subject.current_user
    @non_manufacturer_admin_user = FactoryGirl.create(:user)
    sign_in @non_manufacturer_admin_user
  end

  # LOG BACK IN AS ADMIN -------------------------------------------

  let(:log_back_in_manufacturer_admin) do
    sign_out subject.current_user
    sign_in @manufacturer_admin_user
  end

  # INITIALIZE PARAMETERS -------------------------------------------

  let(:show_params) { { id: @fake_manufacturer } }
  let(:edit_params) { { id: @fake_manufacturer } }
  let(:destroy_params) { { id: @fake_manufacturer } }

  let(:new_main_phone) { '999-999-9999' }
  let(:update_params) do
    {
      id: @fake_manufacturer,
      manufacturer: {
        main_phone: new_main_phone
      }
    }
  end

  # SETUP FOR EACH ADMIN TEST -------------------------------------------

  before(:each) do
    find_a_manufacturer
    login_manufacturer_admin
  end

  after(:each) { Manufacturer.destroy_all }

  # ADMIN TESTS -------------------------------------------

  describe 'GET for Admin Users', :vcr do
    describe 'GET Index', :vcr do
      it 'assigns all manufacturers as @manufacturers' do
        get :index
        expect(assigns(:manufacturers)).to be_present
      end
    end

    describe 'GET show', :vcr do
      it 'assigns the requested manufacturer as @manufacturer' do
        get :show, show_params
        expect(assigns(:manufacturer)).to eq(@fake_manufacturer)
      end
    end

    describe 'GET new', :vcr do
      it 'assigns a new manufacturer as @manufacturer' do
        get :new
        expect(assigns(:manufacturer)).to be_a_new(Manufacturer)
      end
    end

    describe 'GET edit', :vcr do
      it 'assigns the requested manufacturer as @manufacturer' do
        get :edit, edit_params
        expect(assigns(:manufacturer)).to eq(@fake_manufacturer)
      end
    end

    describe 'POST create', :vcr do
      describe 'with valid params' do
        it 'creates a new Manufacturer' do
          expect do
            post :create, create_params
          end.to change(Manufacturer, :count).by(1)
        end

        it 'assigns a newly created manufacturer as @manufacturer' do
          post :create, create_params
          expect(assigns(:manufacturer)).to be_a(Manufacturer)
          expect(assigns(:manufacturer)).to be_persisted
        end

        it 'redirects to the created manufacturer' do
          post :create, create_params
          expect(response).to redirect_to manufacturer_url(assigns(:manufacturer))
        end
      end

      describe 'with invalid params', :vcr do
        it 'assigns a newly created but unsaved manufacturer as @manufacturer' do
          # Trigger the behavior that occurs when invalid params are submitted
          allow_any_instance_of(Manufacturer).to receive(:save).and_return(false)
          post :create, create_params
          expect(assigns(:manufacturer)).to be_a_new(Manufacturer)
        end

        it 're-renders the new template' do
          # Trigger the behavior that occurs when invalid params are submitted
          allow_any_instance_of(Manufacturer).to receive(:save).and_return(false)
          post :create, create_params
          expect(response).to render_template('new')
        end
      end
    end

    describe 'PUT update', :vcr do
      describe 'with valid params' do
        it 'updates the requested manufacturer' do
          put :update, update_params
          assigns(:manufacturer).main_phone.should eq(new_main_phone)
        end

        it 'assigns the requested manufacturer as @manufacturer' do
          put :update, update_params
          expect(assigns(:manufacturer)).to eq(@fake_manufacturer)
        end

        it 'redirects to the manufacturer' do
          put :update, update_params
          expect(response).to redirect_to(@fake_manufacturer)
        end
      end

      describe 'with invalid params' do
        it 'assigns the manufacturer as @manufacturer' do
          allow_any_instance_of(Manufacturer).to receive(:save).and_return(false)
          put :update, update_params
          expect(assigns(:manufacturer)).to eq(@fake_manufacturer)
        end

        it 're-renders the edit template' do
          # Trigger the behavior that occurs when invalid params are submitted
          allow_any_instance_of(Manufacturer).to receive(:save).and_return(false)
          put :update, update_params
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'DELETE destroy', :vcr do
      it 'destroys the requested manufacturer' do
        expect do
          delete :destroy, destroy_params
        end.to change(Manufacturer, :count).by(-1)
      end

      it 'redirects to the manufacturer list' do
        delete :destroy, destroy_params
        expect(response).to redirect_to(manufacturers_url)
      end
    end

    describe 'Authorization Index examples', :vcr do
      it 'Should return success as a owner' do
        get :index
        expect(response).to be_success
      end

      it 'Should return all manufacturers, if service admin' do
        count = Manufacturer.count
        count = ApplicationController::PAGE_COUNT if count > ApplicationController::PAGE_COUNT
        get :index
        expect(response).to be_success
        expect(assigns(:manufacturers).count).to eq(count)
      end
    end # Index authorization

    describe 'Authorization Show examples', :vcr do
      describe 'access by Admin' do
        it 'Return success for a manufacturer accessed by the Admin' do
          get :show, show_params
          expect(response).to be_success
        end

        it 'Find the requested manufacturer accessed by the Admin' do
          get :show, show_params
          expect(assigns(:manufacturer).id).to eq(@fake_manufacturer.id)
        end
      end
    end # Show Admin Access

    describe 'Authorization Edit examples', :vcr do
      describe 'access by Admin' do
        it 'Return success for a manufacturer accessed by Admin' do
          get :edit, edit_params
          expect(response).to be_success
        end

        it 'Find the requested manufacturer owned by Admin' do
          get :edit, edit_params
          expect(assigns(:manufacturer).id).to eq(@fake_manufacturer.id)
        end
      end
    end # Edit Admin Access

    describe 'Authorization Destroy examples', :vcr do
      describe 'with access by Admin' do
        it 'Should redirect to manufacturers_url, upon successful deletion of owned group' do
          delete :destroy, destroy_params
          expect(response).to redirect_to manufacturers_url
        end
      end
    end # Destroy Admin Access
  end # Admin Test Examples

  # NON-ADMIN TESTS -------------------------------------------

  describe 'Non-Admin Authorization Examples', :vcr do
    describe 'Authorization Index Examples' do
      it 'Return success for a manufacturer READ-ONLY access by the Non-Admin' do
        login_non_manufacturer_admin
        get :index
        expect(response).to be_success
      end
    end # Index authorization

    describe 'Authorization Show Examples' do
      it 'Return success for a manufacturer READ-ONLY access by the Non-Admin' do
        login_non_manufacturer_admin
        get :show, show_params
        expect(response).to be_success
      end
    end # Show authorization

    describe 'Authorization Edit Examples' do
      it 'Redirect to admin_oops_url for a manufacturer NOT accessible by the user' do
        login_non_manufacturer_admin
        get :edit, edit_params
        expect(response).to redirect_to admin_oops_url
      end
    end # Edit authorization

    describe 'Authorization Create Examples' do
      it 'Redirect to admin_oops_url for a manufacturer NOT accessible by the user' do
        login_non_manufacturer_admin
        get :create, create_params
        expect(response).to redirect_to admin_oops_url
      end
    end # Create authorization

    describe 'Authorization Destroy Examples' do
      it 'Redirect to admin_oops_url for a manufacturer NOT accessible by the user' do
        login_non_manufacturer_admin
        delete :destroy, destroy_params
        expect(response).to redirect_to admin_oops_url
      end
    end # Destroy authorization
  end # Non-Admin Test Examples
end
