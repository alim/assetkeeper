require 'spec_helper'

describe AssetItemsController, :type => :controller do

  include_context 'user_setup'
  include_context 'organization_setup'
  include_context 'asset_setup'

  ## TEST SETUP --------------------------------------------------------
  let(:name) {"Sample Asset"}
  let(:desc) {"The sample asset for testing"}
  let(:loc) {'NW corner'}
  let(:lat) {'42.3346459'}
  let(:long) {'-83.8820567'}
  let(:material) {'Cast iron'}
  let(:install_date) {'02/15/2015'}

  let(:asset) { AssetItem.where(user_id: @owner.id).first }

   let(:login_nonowner_no_org) {
    sign_out subject.current_user
    sign_in FactoryGirl.create(:user)
  }

  # Not an owner but part of the organization
  let(:login_nonowner_in_org) {
    sign_out subject.current_user

    # Find a user that is part of the org, but not the asset creator
    sign_in User.find((@organization.users.pluck(:id).reject {|id| id == asset.user.id}).last)
  }

  before(:each) {
    # Setup asset with users
    assets_with_users
    create_users

    # Create a organization and make the owner one the asset user
    single_organization_with_users

    # Setup asset to belong to the organization
    @organization.asset_items << FactoryGirl.create(:asset_item, user: @owner)
    AssetItem.all.each { |asset| @organization.asset_items << asset }

    sign_in @owner
  }

  after(:each) {
    User.delete_all
    AssetItem.delete_all
    Organization.delete_all
  }

  # INDEX TESTS --------------------------------------------------------

  describe "GET index" do
    describe "valid tests" do
      it "should return success" do
        get :index
        expect(response).to be_success
      end

      it "should render the index template" do
        get :index
        expect(response).to render_template :index
      end

      it "assigns all assets as asset_items" do
        count = AssetItem.all.count
        count = ApplicationController::PAGE_COUNT if count > ApplicationController::PAGE_COUNT
        get :index
        expect(assigns(:asset_items).count).to eq(count)
      end
    end

    describe "invalid examples" do
      it "should redirect to sign in, if not signed in" do
  	    sign_out subject.current_user
  	    get :index
  	    expect(response).to redirect_to new_user_session_url
  	  end

  	  it "Should still return success, if no groups present" do
  	    AssetItem.delete_all
  	    get :index
  	    expect(response).to be_success
  	    expect(assigns(:asset_items).count).to eq(0)
  	  end
    end

    describe "authorization examples" do
      it "Should return success as a customer" do
        get :index
        expect(response).to be_success
      end

      it "Should only access assets that user owns" do
        get :index
        expect(assigns(:asset_items).count).not_to eq(0)
        assigns(:asset_items).each do |asset_item|
          expect(asset_item.user.id).to eq(asset.user.id)
        end
      end

      it "Should not access any assets, if not asset owner and not in organization" do
        login_nonowner_no_org
        get :index
        expect(assigns(:asset_items).count).to eq(0)
      end

      it "Should access all assets in organization" do
        login_nonowner_in_org
        get :index

        expect(assigns(:asset_items).count).to be > 0
        assigns(:asset_items).each do |asset_item|
          expect(asset_item.organization_id).to eq(subject.current_user.organization_id)
        end
      end

      it "Should return all assets, if service admin" do
        login_admin
        get :index
        expect(response).to be_success
        expect(assigns(:asset_items).count).not_to eq(0)
        expect(assigns(:asset_items).count).to eq(AssetItem.count)
      end
    end # Index authorization
  end

  ## SHOW TESTS --------------------------------------------------------

  describe "GET show" do
    let(:show_params) {
      { id: asset.id }
    }

    describe "Valid examples" do
      it "Should return with success" do
        get :show, show_params
        expect(response).to be_success
      end

      it "Should use the show template" do
        get :show, show_params
        expect(response).to render_template :show
      end

      it "Should find matching asset" do
        get :show, show_params
        expect(assigns(:asset_item).id).to eq(asset.id)
      end
    end # Valid examples

    describe "Invalid examples" do
       it "Should not succeed, if not logged in" do
        sign_out subject.current_user
        get :show, show_params
        expect(response).not_to be_success
      end

      it "Should redirect, if not logged in" do
        sign_out subject.current_user
        get :show, show_params
        expect(response).to redirect_to new_user_session_url
      end

      it "Should redirect to admin_oops_url, if record not found" do
        get :show, {id: '99999'}
        expect(response).to redirect_to admin_oops_url
      end

      it "Should flash an alert message, if record not found" do
        get :show, {id: '99999'}
        expect(flash[:alert]).to match(/^We are unable to find the requested AssetItem/)
      end

    end

    describe "Authorization examples" do
      describe "access by owner" do
        it "Return success for a asset owned by the user" do
          get :show, show_params
          expect(response).to be_success
        end

        it "Find the requested asset owned by the user" do
          get :show, show_params
          expect(assigns(:asset_item).id).to eq(asset.id)
        end
      end # access by owner

      describe "access by non-owner and non-organization member" do
        before(:each) { login_nonowner_no_org }

        it "Redirect to admin_oops_url for a asset NOT owned by the user" do
          get :show, show_params
          expect(response).to redirect_to admin_oops_url
        end

        it "Flash alert message for a group NOT owned by the user" do
          get :show, show_params
          expect(flash[:alert]).to match(/You are not authorized to access the requested #{asset.class}/)
        end
      end  # non-owner access

      describe "access by non-owner but a organization member" do
        before(:each){
          login_nonowner_in_org
        }

        it "Return success for the requested asset by the user" do
          get :show, show_params
          expect(response).to be_success
        end

        it "Find the requested asset" do
          get :show, show_params
          expect(assigns(:asset_item).id).to eq(asset.id)
        end

        it "The requested asset should not be owned by the signed user" do
          expect(@organization.users.pluck(:id)).to include(asset.user_id)
          get :show, show_params
          expect(assigns(:asset_item).user.id).not_to eq(subject.current_user.id)
        end
      end # non-owner, but group member

      describe "access by admin user" do
        before(:each) { login_admin }

        it "Return success for a asset using admin login" do
          get :show, show_params
          expect(response).to be_success
        end

        it "Find the requested asset with admin login" do
          get :show, show_params
          expect(assigns(:asset_item).id).to eq(asset.id)
        end

        it "AssetItem should have different owner than admin" do
          get :show, show_params
          expect(assigns(:asset_item).user.id).not_to eq(subject.current_user.id)
        end
      end # admin user
    end # Show authorization examples
  end

  ## NEW TESTS ---------------------------------------------------------

  describe "GET new" do
    describe "Valid tests" do
      it "Should return success" do
        get :new
        expect(response).to be_success
      end

      it "assigns a new asset as asset_item" do
        get :new
        expect(assigns(:asset_item)).to be_a_new(AssetItem)
      end

      it "Should use the new template" do
        get :new
        expect(response).to render_template :new
      end
		end # Valid tests

		describe "Invalid tests" do
		  it "Should redirect, if not logged in" do
        sign_out subject.current_user
        get :new
        expect(response).to redirect_to new_user_session_url
      end
		end # Invalid examples

		describe "Authorization examples" do
     it "Return success for a new asset owned by the current_user" do
        get :new
        expect(response).to be_success
        expect(response).to render_template :new
      end

      it "Return success for a new asset logged in as admin" do
        login_admin
        get :new
        expect(response).to be_success
        expect(response).to render_template :new
      end
		end # New authorization examples
  end

  ## EDIT TESTS --------------------------------------------------------
  describe "GET edit" do
    let(:edit_params) { {id: asset.id} }

    describe "Valid tests" do
      it "Should return success" do
        get :edit, edit_params
        expect(response).to be_success
      end

      it "Should use the edit template" do
        get :edit, edit_params
        expect(response).to render_template :edit
      end

      it "Should find the asset record" do
        get :edit, edit_params
        expect(assigns(:asset_item).id).to eq(asset.id)
      end
		end # Valid tests

		describe "Invalid tests" do
		  it "Should redirect, if not logged in" do
        sign_out subject.current_user
        get :edit, edit_params
        expect(response).to redirect_to new_user_session_url
      end

      it "Should redirect to admin_oops_url for invalid group id" do
        get :edit, {id: '090909'}
        expect(response).to redirect_to admin_oops_url
      end

      it "Should flash alert message for invalid group id" do
        get :edit, {id: '090909'}
        expect(flash[:alert]).to match(/We are unable to find the requested AssetItem/)
      end
		end # Invalid tests

    describe "Authorization examples" do
      describe "access by owner" do
        it "Return success for a asset owned by the user" do
          get :edit, edit_params
          expect(response).to be_success
        end

        it "Find the requested asset owned by the user" do
          get :edit, edit_params
          expect(assigns(:asset_item).id).to eq(asset.id)
        end

        it "AssetItem user.id should match signed_in_user.id" do
          get :edit, edit_params
          expect(assigns(:asset_item).user.id).to eq(subject.current_user.id)
        end
      end # access by owner

      describe "access by non-owner and non-organization member" do
        before(:each) { login_nonowner_no_org }

        it "Redirect to admin_oops_url for a asset NOT owned by the user" do
          get :edit, edit_params
          expect(response).to redirect_to admin_oops_url
        end

        it "Flash alert message for a group NOT owned by the user" do
          get :edit, edit_params
          expect(flash[:alert]).to match(/You are not authorized to access the requested #{asset.class}/)
        end
      end

      describe "access by non-owner and organization member" do
        before(:each){
          login_nonowner_in_org
        }

        it "Return success for a asset by a member user" do
          get :edit, edit_params
          expect(response).to be_success
        end

        it "Find the requested asset owned by a member user" do
          get :edit, edit_params
          expect(assigns(:asset_item).id).to eq(asset.id)
        end

        it "AssetItem user.id should match signed_in_user.id" do
          expect(@organization.users.pluck(:id)).to include(asset.user_id)
          get :edit, edit_params
          expect(assigns(:asset_item).user.id).not_to eq(subject.current_user.id)
        end
      end

      describe "access by admin user" do
        before(:each) { login_admin }

        it "Return success for a asset owned by the user" do
          get :edit, edit_params
          expect(response).to be_success
        end

        it "Find the requested asset owned by the user" do
          get :edit, edit_params
          expect(assigns(:asset_item).id).to eq(asset.id)
        end

        it "AssetItem user.id should match admin_user id" do
          get :edit, edit_params
          expect(assigns(:asset_item).user.id).not_to eq(subject.current_user.id)
        end
      end
    end # Edit authorization examples
  end

  ## CREATE TESTS ------------------------------------------------------

  describe "POST create" do

    let(:asset_params){
      {asset_item:
        {
          name: name,
          description: desc,
          organization_id: [@organization.id],
          location: loc,
          latitude: lat,
          longitude: long,
          material: material,
          date_installed: install_date,
          condition: AssetItem::CONDITION_VALUES[:good],
          failure_probability: AssetItem::FAILURE_VALUES[:unlikely],
          failure_consequence: AssetItem::CONSEQUENCE_VALUES[:high],
          status: AssetItem::STATUS_VALUES[:operational]
        }
      }
    }

    describe "with valid params" do

      it "creates a new AssetItem" do
        expect {
          post :create, asset_params
        }.to change(AssetItem, :count).by(1)
      end

      it "assigns a newly created asset as asset" do
        post :create, asset_params
        expect(assigns(:asset_item)).to be_a(AssetItem)
        expect(assigns(:asset_item)).to be_persisted
      end

      it "redirects to the created asset" do
        post :create, asset_params
        expect(response).to redirect_to(assigns(:asset_item))
      end

      it "should update asset with name" do
        post :create, asset_params
        expect(assigns(:asset_item).name).to eq(name)
      end

      it "should update asset with description" do
        post :create, asset_params
        expect(assigns(:asset_item).description).to eq(desc)
      end

      it "should update the organization relationship" do
        post :create, asset_params
        expect(assigns(:asset_item).organization_id).to eq(@organization.id)
      end

      it 'should update location' do
        post :create, asset_params
        expect(assigns(:asset_item).location).to eq(loc)
      end

      it 'should update latitude' do
        post :create, asset_params
        expect(assigns(:asset_item).latitude).to eq(lat)
      end

      it 'should update longitude' do
        post :create, asset_params
        expect(assigns(:asset_item).longitude).to eq(long)
      end

      it 'should update material' do
        post :create, asset_params
        expect(assigns(:asset_item).material).to eq(material)
      end

      it 'should update date_installed' do
        post :create, asset_params
        expect(assigns(:asset_item).date_installed).to eq(DateTime.new(2015,02,15))
      end
      # describe "file upload examples" do
      #   before(:each) do
      #     @file = fixture_file_upload('spec/fixtures/test_doc.pdf',
      #       'application/pdf')
      #     asset_params[:project][:charter_doc] = @file
      #   end

      #   it "should allow attaching a pdf file" do
      #     post :create, project_params
      #     expect(response).to redirect_to(assigns(:project))
      #   end

      #   it "should upload file and set file name attribute" do
      #     post :create, project_params
      #     expect(assigns(:project).charter_doc_file_name).to match(/test_doc.pdf/)
      #   end

      #   it "should upload file and set file url attribute" do
      #     post :create, project_params
      #     expect(assigns(:project).charter_doc.url).to match(/test_doc.pdf/)
      #   end

      #   it "should upload file and set file content_type attribute" do
      #     post :create, project_params
      #     expect(assigns(:project).charter_doc_content_type).to match(/pdf/)
      #   end
      # end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved asset as asset_item" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(AssetItem).to receive(:save).and_return(false)
        post :create, {:asset_item => { "name" => "invalid value" }}
        expect(assigns(:asset_item)).to be_a_new(AssetItem)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(AssetItem).to receive(:save).and_return(false)
        post :create, {:asset_item => { "name" => "invalid value" }}
        expect(response).to render_template("new")
      end

      it "sets validation errors for missing name" do
        asset_params[:asset_item][:name] = nil
        post :create, asset_params
        expect(assigns(:verrors)[0]).to match(/Name can't be blank/)
      end

      it "sets validation errors for missing description" do
        asset_params[:asset_item][:description] = nil
        post :create, asset_params
        expect(assigns(:verrors)[0]).to match(/Description can't be blank/)
      end

      it "sets validation errors for missing material" do
        asset_params[:asset_item][:material] = nil
        post :create, asset_params
        expect(assigns(:verrors)[0]).to match(/Material can't be blank/)
      end

      it "sets validation errors for missing condition" do
        asset_params[:asset_item][:condition] = nil
        post :create, asset_params
        expect(assigns(:verrors)[0]).to match(/Condition can't be blank/)
      end

      it "sets validation errors for missing failure_probability" do
        asset_params[:asset_item][:failure_probability] = nil
        post :create, asset_params
        expect(assigns(:verrors)[0]).to match(/Failure probability can't be blank/)
      end

      it "sets validation errors for missing failure_consequence" do
        asset_params[:asset_item][:failure_consequence] = nil
        post :create, asset_params
        expect(assigns(:verrors)[0]).to match(/Failure consequence can't be blank/)
      end

      it "sets validation errors for missing status" do
        asset_params[:asset_item][:status] = nil
        post :create, asset_params
        expect(assigns(:verrors)[0]).to match(/Status can't be blank/)
      end

    end # invalid params

    describe "Authorization examples" do
      it "should create a asset with customer's id" do
        post :create, asset_params
        expect(assigns(:asset_item).user.id).to eq(subject.current_user.id)
      end

      it "should create a asset with admin user's id" do
        login_admin
        post :create, asset_params
        expect(assigns(:asset_item).user.id).to eq(subject.current_user.id)
        expect(assigns(:asset_item).user.role).to eq(User::SERVICE_ADMIN)
      end
    end # Create authorization examples
  end

  ## UPDATE TESTS ------------------------------------------------------

  describe "PUT update" do
   let(:update_params){
      { id: asset.id,
        asset_item:
        {
          name: name + 'PhD',
          description: desc + 'more description',
          organization_id: [@organization.id],
          location: loc + 'lower level',
          latitude: lat + '99',
          longitude: long + '99',
          material: material + ' and cement',
          date_installed: '03/15/2015',
          condition: AssetItem::CONDITION_VALUES[:very_good],
          failure_probability: AssetItem::FAILURE_VALUES[:very_unlikely],
          failure_consequence: AssetItem::CONSEQUENCE_VALUES[:moderate],
          status: AssetItem::STATUS_VALUES[:ordered]
        }
      }
    }

    describe "with valid params" do
      it "Should redirect to AssetItem#show path" do
        put :update, update_params
        expect(response).to redirect_to asset_item_url(asset)
      end

      it "Should find the correct asset_item record" do
        put :update, update_params
        expect(assigns(:asset_item).id).to eq(asset.id)
      end

      it "Should update asset_item with description" do
        put :update, update_params
        expect(assigns(:asset_item).description).to eq(update_params[:asset_item][:description])
      end

      it "Should update the asset_item name" do
        put :update, update_params
        expect(assigns(:asset_item).name).to eq(update_params[:asset_item][:name])
      end

      it "Should update the organization relation" do
        put :update, update_params
        expect(assigns(:asset_item).organization_id).to eq(@organization.id)
      end

      it "Should update the asset_item location" do
        put :update, update_params
        expect(assigns(:asset_item).location).to eq(update_params[:asset_item][:location])
      end

      it "Should update the asset_item latitude" do
        put :update, update_params
        expect(assigns(:asset_item).latitude).to eq(update_params[:asset_item][:latitude])
      end

      it "Should update the asset_item longitude" do
        put :update, update_params
        expect(assigns(:asset_item).longitude).to eq(update_params[:asset_item][:longitude])
      end

      it "Should update the asset_item material" do
        put :update, update_params
        expect(assigns(:asset_item).material).to eq(update_params[:asset_item][:material])
      end

      it "Should update the asset_item date_installed" do
        put :update, update_params
        expect(assigns(:asset_item).date_installed).to eq(DateTime.new(2015,03,15))
      end

      it "Should update the asset_item condition" do
        put :update, update_params
        expect(assigns(:asset_item).condition).to eq(update_params[:asset_item][:condition])
      end

      it "Should update the asset_item failure_probability" do
        put :update, update_params
        expect(assigns(:asset_item).failure_probability).to eq(update_params[:asset_item][:failure_probability])
      end

      it "Should update the asset_item failure_consequence" do
        put :update, update_params
        expect(assigns(:asset_item).failure_consequence).to eq(update_params[:asset_item][:failure_consequence])
      end

      it "Should update the asset_item status" do
        put :update, update_params
        expect(assigns(:asset_item).status).to eq(update_params[:asset_item][:status])
      end
      # describe "file upload examples" do
      #   before(:each) do
      #     @file = fixture_file_upload('spec/fixtures/test_doc.pdf',
      #       'application/pdf')
      #     update_params[:asset_item][:charter_doc] = @file
      #   end

      #   it "should allow attaching a pdf file" do
      #     put :update, update_params
      #     expect(response).to redirect_to(assigns(:asset_item))
      #   end

      #   it "should upload file and set file name attribute" do
      #     put :update, update_params
      #     expect(assigns(:asset_item).charter_doc_file_name).to match(/test_doc.pdf/)
      #   end

      #   it "should upload file and set file url attribute" do
      #     put :update, update_params
      #     expect(assigns(:asset_item).charter_doc.url).to match(/test_doc.pdf/)
      #   end

      #   it "should upload file and set file content_type attribute" do
      #     put :update, update_params
      #     expect(assigns(:asset_item).charter_doc_content_type).to match(/pdf/)
      #   end
      # end
    end # with valid parameters

    describe "with invalid params" do
      it "Should redirect to sign_in, if not logged in" do
        sign_out subject.current_user
        put :update, update_params
        expect(response).to redirect_to new_user_session_url
      end

      it "Should redirect to admin_oops_url, if AssetItem not found" do
        params = update_params
        params[:id] = '99999'
        put :update, params
        expect(response).to redirect_to admin_oops_url
      end

      it "Should flash error message, if AssetItem not found" do
        params = update_params
        params[:id] = '99999'
        put :update, params
        expect(flash[:alert]).to match(/We are unable to find the requested AssetItem/)
      end

      it "Should render the edit template, if AssetItem could not save" do

        # Setup a method stub for the group method save
        # to return nil, which indicates a failure to save the account
        allow_any_instance_of(AssetItem).to receive(:update_attributes).and_return(nil)

        post :update, update_params
        expect(response).to render_template :edit
      end
    end # invalid examples

    describe "Authorization tests" do
      describe "with access by owner" do
        it "Redirect to asset_item_url for a asset_item owned by the user" do
          get :update, update_params
          expect(response).to redirect_to asset_item_url(asset)
        end

        it "Find the requested asset_item owned by the user" do
          get :update, update_params
          expect(assigns(:asset_item).id).to eq(asset.id)
        end

        it "AssetItem user.id should match signed_in_user.id" do
          get :update, update_params
          expect(assigns(:asset_item).user.id).to eq(subject.current_user.id)
        end
      end # access by owner

      describe "access by non-owner and non-organization member" do
        before(:each) { login_nonowner_no_org }

        it "Redirect to admin_oops_url for a asset_item NOT owned by the user" do
          get :update, update_params
          expect(response).to redirect_to admin_oops_url
        end

        it "Flash alert message for a AssetItem NOT owned by the user" do
          get :update, update_params
          expect(flash[:alert]).to match(/You are not authorized to access the requested #{asset.class}/)
        end
      end

      describe "access by non-owner and organization member" do
        before(:each){
          login_nonowner_in_org
        }

        it "Redirect to asset_item_url for a asset_item by a member user" do
          get :update, update_params
          expect(response).to redirect_to asset_item_url(asset)
        end

        it "Find the requested asset_item owned by a member user" do
          get :update, update_params
          expect(assigns(:asset_item).id).to eq(asset.id)
        end

        it "AssetItem user.id should match signed_in_user.id" do
          get :update, update_params
          expect(assigns(:asset_item).user.id).not_to eq(subject.current_user.id)
        end

        it "AssetItem organization.id should match signed_in_user.organization.id" do
          get :update, update_params
          expect(assigns(:asset_item).organization.id).to eq(subject.current_user.organization.id)
        end
      end

      describe "access by admin user" do
        before(:each) { login_admin }

        it "Redirect to asset_item_url for a asset_item owned by the user" do
          get :update, update_params
          expect(response).to redirect_to asset_item_url(asset)
        end

        it "Find the requested asset_item owned by the user" do
          get :update, update_params
          expect(assigns(:asset_item).id).to eq(asset.id)
        end

        it "AssetItem user.id should match admin_user id" do
          get :update, update_params
          expect(assigns(:asset_item).user.id).not_to eq(subject.current_user.id)
        end
      end
    end # Update authorization examples
  end

  ## DESTROY TESTS -----------------------------------------------------

  describe "DELETE destroy" do
    let(:destroy_params) {
      {
        id: asset.id
      }
    }

    describe "Valid examples" do
      it "Should redirect to #index" do
        delete :destroy, destroy_params
        expect(response).to redirect_to asset_items_url
      end

      it "Should display a success message" do
        delete :destroy, destroy_params
        expect(flash[:notice]).to match(/Asset #{asset.name} was successfully deleted./)
      end

      it "Should delete asset_item record" do
        expect{
          delete :destroy, destroy_params
        }.to change(AssetItem, :count).by(-1)
      end

      it "Should should not destroy any related organizations" do
        org_count = Organization.count
        expect(org_count).not_to eq(0)
        expect {
          delete :destroy, destroy_params
        }.to change(Organization, :count).by(0)
        expect(Organization.count).to eq(org_count)
      end
    end # Valid examples

    describe "Invalid examples" do
      it "Should redirect to sign_in, if not logged in" do
        sign_out subject.current_user
        delete :destroy, destroy_params
        expect(response).to redirect_to new_user_session_url
      end

      it "Should redirect to admin_oops_url, if no group record found" do
        params = destroy_params
        params[:id] = '00999'
        delete :destroy, params
        expect(response).to redirect_to admin_oops_url
      end

      it "Should flash an error message, if no group record found" do
        params = destroy_params
        params[:id] = '00999'
        delete :destroy, params
        expect(flash[:alert]).to match(/We are unable to find the requested AssetItem/)
      end
    end # Invalid examples

    describe "Authorization examples" do
      describe "with access by owner" do
        it "Should redirect to asset_items_url, upon succesfull deletion of owned group" do
          delete :destroy, destroy_params
          expect(response).to redirect_to asset_items_url
        end

        it "Deleted asset_item should have same owner id as login" do
          delete :destroy, destroy_params
          expect(assigns(:asset_item).user.id).to eq(subject.current_user.id)
        end

        it "Should reduce the number of AssetItem records by 1" do
          expect{
            delete :destroy, destroy_params
          }.to change(AssetItem, :count).by(-1)
        end
      end

      describe "access by non-owner and non-group member" do
        before(:each) { login_nonowner_no_org }

        it "Redirect to admin_oops_url for a asset_item NOT owned by the user" do
          delete :destroy, destroy_params
          expect(response).to redirect_to admin_oops_url
        end

        it "Flash alert message for a group NOT owned by the user" do
          delete :destroy, destroy_params
          expect(flash[:alert]).to match(/You are not authorized to access the requested #{asset.class}/)
        end

        it "Should not delete a AssetItem record" do
          expect {
            delete :destroy, destroy_params
          }.to change(AssetItem, :count).by(0)
        end
      end

      describe "access by non-owner and in organization" do
        before(:each){
          login_nonowner_in_org
        }

        it "Should redirect to asset_items_url, upon successful deletion" do
          delete :destroy, destroy_params
          expect(response).to redirect_to asset_items_url
        end

        it "Deleted asset_item should NOT have same owner id as login" do
          delete :destroy, destroy_params
          expect(assigns(:asset_item).user.id).not_to eq(subject.current_user.id)
        end

        it "Deleted asset_item should have same organization_id as user" do
          delete :destroy, destroy_params
          expect(assigns(:asset_item).organization.id).to eq(subject.current_user.organization.id)
        end

        it "Should reduce the number of AssetItem records by 1" do
          expect{
            delete :destroy, destroy_params
          }.to change(AssetItem, :count).by(-1)
        end

        it "Should not reduce the number of organizations" do
          org_count = Organization.count
          expect{
            delete :destroy, destroy_params
          }.to change(Organization, :count).by(0)
        end
      end

      describe "as a service admin" do
        before(:each) { login_admin }

        it "Should redirect to asset_items_url, upon succesfull deletion of owned group" do
          delete :destroy, destroy_params
          expect(response).to redirect_to asset_items_url
        end

        it "Should reduce the number of AssetItem records by 1" do
          expect{
            delete :destroy, destroy_params
          }.to change(AssetItem, :count).by(-1)
        end

        it "Deleted asset_item should have different owner id from admin" do
          delete :destroy, destroy_params
          expect(assigns(:asset_item).user.id).not_to eq(subject.current_user.id)
        end
      end # service admin

    end # Authorization examples for delete
  end # delete examples

end
