require 'spec_helper'

describe OrganizationsController, :type => :controller do

  include_context 'user_setup'
  include_context 'organization_setup'
  include_context 'project_setup'

  # TEST SETUP ---------------------------------------------------------
  let(:find_one_user) {
    @customer = User.where(role: User::CUSTOMER).where(:account.exists => true).first
  }

  let(:login_as_organization_owner){
    sign_in @owner
    @signed_in_user = @owner
    expect(subject.current_user).not_to be_nil
  }

  let(:login_nonowner) {
    sign_out @signed_in_user
    @signed_in_user = User.where(:id.ne => @owner.id).first
    sign_in @signed_in_user
  }

  let(:login_nonmember) {
    sign_out @signed_in_user
    @signed_in_user = FactoryGirl.create(:user)
    sign_in @signed_in_user
  }

  let(:create_projects){
      3.times.each do
        FactoryGirl.create(:project, user: @signed_in_user)
      end
  }

  before(:each) {
    single_organization_with_users
    find_one_user
    login_as_organization_owner
    expect(subject.current_user).not_to be_nil
  }

  after(:each) {
    delete_users
    Organization.delete_all
    ActionMailer::Base.deliveries.clear
  }

  # INDEX ACTION TESTS -------------------------------------------------

  describe "GET index" do
    context "as a organization owner" do
      it "Should redirect to user's organization" do
        get :index
        expect(response).to redirect_to @organization
      end

      it "Should redirect to new_organization_path if none exists" do
        Organization.delete_all
        get :index
        expect(response).to redirect_to new_organization_path
      end


      it "Should redirect to sign in, if not signed in" do
        sign_out @signed_in_user
        get :index
        expect(response).to redirect_to new_user_session_url
      end
    end

    context "as a service admin" do
      it "Should return all organizations, if service admin" do
        login_admin
        multiple_organizations
        get :index
        expect(response).to be_success
        expect(assigns(:organizations).count).not_to eq(0)
        expect(assigns(:organizations).count).to eq(Organization.count)
      end
    end
  end


  # SHOW ACTION TESTS --------------------------------------------------

  describe "GET show" do
    let(:show_params) {
      { id: @organization.id }
    }

    context "as a customer and organization owner" do

      it "Should return with success" do
        get :show, show_params
        expect(response).to be_success
      end

      it "Should use the show template" do
        get :show, show_params
        expect(response).to render_template :show
      end

      it "Should find matching organization record" do
        get :show, show_params
        expect(assigns(:organization).id).to eq(@organization.id)
      end

      it "Should find matching owner email" do
        owner = User.find(@organization.owner_id)
        get :show, show_params
        expect(assigns(:user).email).to eq(owner.email)
      end

      it "Should find all users for the organization" do
        uids = @organization.users.all.pluck(:id).sort
        expect(uids).not_to be_empty
        get :show, show_params
        expect(assigns(:organization).users.pluck(:id).sort).to eq(uids)
      end

      it "Return success for a organization owned by the user" do
        login_as_organization_owner
        organization = Organization.where(owner_id: @owner.id).first
        get :show, {id: organization.id}
        expect(response).to be_success
      end

      it "Find the requested organization owned by the user" do
        login_as_organization_owner
        organization = Organization.where(owner_id: @owner.id).first
        get :show, {id: organization.id}
        expect(assigns(:organization).id).to eq(organization.id)
      end

      it "Organization owner_id should match requested organization owner_id" do
        login_as_organization_owner
        organization = Organization.where(owner_id: @owner.id).first
        get :show, {id: organization.id}
        expect(assigns(:organization).owner_id).to eq(@owner.id)
      end

      context 'Non-owner that is a member' do
        it "Should find matching organization record" do
          login_nonowner
          get :show, show_params
          expect(assigns(:organization).id).to eq(@organization.id)
        end

        it "Organization owner_id should match requested organization owner_id" do
          login_nonowner
          get :show, show_params
          expect(assigns(:organization).owner_id).to eq(@owner.id)
        end
      end

      context "Invalid examples" do
        it "Should not succeed, if not logged in" do
          sign_out @signed_in_user
          get :show, show_params
          expect(response).not_to be_success
        end

        it "Should redirect, if not logged in" do
          sign_out @signed_in_user
          get :show, show_params
          expect(response).to redirect_to new_user_session_url
        end

        it "Should redirect to #index, if record not found" do
          get :show, {id: '99999'}
          expect(response).to redirect_to admin_oops_url
        end

        it "Should flash an alert message, if record not found" do
          get :show, {id: '99999'}
          expect(flash[:alert]).to match(/^We are unable to find the requested Organization/)
        end

        it "Should flash an alert if we cannot find a organization owner and non-member" do
          login_nonmember

          get :show, show_params
          expect(flash[:alert]).to match(/You are not authorized to access the requested Organization/)
        end
      end
    end

    context "as admin" do
      it "Return success for a organization with different owner than admin" do
        login_admin
        organization = Organization.where(owner_id: @owner.id).first
        get :show, {id: organization.id}
        expect(response).to be_success
      end

      it "Find the requested organization with different owner than admin" do
        login_admin
        organization = Organization.where(owner_id: @owner.id).first
        get :show, {id: organization.id}
        expect(assigns(:organization).id).to eq(organization.id)
      end

      it "Organization should have different owner than admin" do
        login_admin
        organization = Organization.where(owner_id: @owner.id).first
        get :show, {id: organization.id}
        expect(assigns(:organization).owner_id).not_to eq(@signed_in_user.id)
      end
    end # Show authorization examples
  end

  # NEW TESTS ----------------------------------------------------------
  describe "GET new" do
    context "as a customer and organization owner" do
      it "Should return success" do
        get :new
        expect(response).to be_success
      end

      it "Should use the new template" do
        get :new
        expect(response).to render_template :new
      end

      it "Should set a new organization record" do
        get :new
        expect(assigns(:organization)).to be_present
      end

      context "Invalid tests" do
        it "Should redirect, if not logged in" do
          sign_out @signed_in_user
          get :new
          expect(response).to redirect_to new_user_session_url
        end
      end # Invalid examples
    end # Valid tests

    context "as and admin user" do
      it "Return success for a new organization logged in as admin" do
        login_admin
        get :new
        expect(response).to be_success
        expect(response).to render_template :new
      end
    end # New authorization examples

  end

  # EDIT ACTION TESTS --------------------------------------------------

  describe "GET edit" do
    let(:edit_params) { {id: @organization.id} }

    context "as a customer and organization owner" do
      it "Should return success" do
        get :edit, edit_params
        expect(response).to be_success
      end

      it "Should use the edit template" do
        get :edit, edit_params
        expect(response).to render_template :edit
      end

      it "Should find the organization record" do
        get :edit, edit_params
        expect(assigns(:organization).id).to eq(@organization.id)
      end

      it "Organization owner_id should match requested organization owner_id" do
        organization = Organization.where(owner_id: @owner.id).first
        get :edit, {id: organization.id}
        expect(assigns(:organization).owner_id).to eq(@owner.id)
      end

      context "Invalid tests" do
        it "Should redirect, if not logged in" do
          sign_out @signed_in_user
          get :edit, edit_params
          expect(response).to redirect_to new_user_session_url
        end

        it "Should redirect to organizations_url for invalid organization id" do
          get :edit, {id: '090909'}
          expect(response).to redirect_to admin_oops_url
        end

        it "Should flash alert message for invalid organization id" do
          get :edit, {id: '090909'}
          expect(flash[:alert]).to match(/We are unable to find the requested Organization/)
        end
      end # Invalid tests

    end # Valid tests


    describe "as and admin user" do

      it "Return success for a organization with different owner than admin" do
        login_admin
        organization = Organization.where(owner_id: @owner.id).first
        get :edit, {id: organization.id}
        expect(response).to be_success
      end

      it "Find the requested organization with different owner than admin" do
        login_admin
        organization = Organization.where(owner_id: @owner.id).first
        get :edit, {id: organization.id}
        expect(assigns(:organization).id).to eq(organization.id)
      end

      it "Organization should have different owner than admin" do
        login_admin
        organization = Organization.where(owner_id: @owner.id).first
        get :edit, {id: organization.id}
        expect(assigns(:organization).owner_id).not_to eq(@signed_in_user.id)
      end

      it "Redirect to admin_oops for a organization NOT owned by the user" do
        login_nonowner
        get :edit, {id: @organization.id}
        expect(response).to redirect_to admin_oops_url
      end

      it "Flash alert message for a organization NOT owned by the user" do
        login_nonowner
        get :edit, {id: @organization.id}
        expect(flash[:alert]).to match(/You are not authorized to access the requested #{@organization.class}/)
      end
    end # Edit authorization examples
  end

  # CREATE ACTION TESTS ------------------------------------------------
  describe "POST create" do
    let(:name) {"Sample Organization"}
    let(:desc) {"The sample organization for testing"}
    let(:members) {"one@example.com\ntwo@example.com\nthree@example.com\n"}

    let(:valid_organization_params){
      {organization: {
        name: name,
        description: desc,
        members: members
      }}
    }

    before(:each) {
      Organization.destroy_all
    }

    context "as a customer and organization owner" do
      it "Should return success with valid organization fields" do
        post :create, valid_organization_params
        expect(response).to redirect_to organization_url(assigns(:organization))
        expect(flash[:notice]).to match(/Organization was successfully created./)
      end

      it "Should update organization with name" do
        post :create, valid_organization_params
        expect(assigns(:organization).name).to eq(name)
      end

      it "Should update organization with description" do
        post :create, valid_organization_params
        expect(assigns(:organization).description).to eq(desc)
      end

      it "Should create new user records for each email address" do
        post :create, valid_organization_params
        members.split.each do |email|
          expect(assigns(:organization).users.where(email: email).first).to be_present
        end
      end

      it "Should notify each user of their account" do
        post :create, valid_organization_params
        ActionMailer::Base.deliveries.each do |delivery|
          expect(members).to match(/#{delivery.to}/)
        end
      end

      it "Should relate the correct resources to the organization" do
        create_projects
        project_ids = Project.all.pluck(:id)
        valid_organization_params[:organization][:resource_ids] = project_ids
        post :create, valid_organization_params
        expect(assigns(:organization).project_ids.sort).to eq(project_ids.sort)
      end

      it "Should relate the correct number of resources to the organization" do
        create_projects
        project_ids = Project.all.pluck(:id)
        valid_organization_params[:organization][:resource_ids] = project_ids
        post :create, valid_organization_params
        expect(assigns(:organization).projects.count).to eq(project_ids.count)
      end

      context "invalid examples" do
        it "Should redirect to sign_in, if not logged in" do
          sign_out @signed_in_user
          post :create, valid_organization_params
          expect(response).to redirect_to new_user_session_url
        end

        it "Should render the new template, if account could not save" do

          # Setup a method stub for the Organization method save
          # to return nil, which indicates a failure to save the account
          allow_any_instance_of(Organization).to receive(:save).and_return(nil)

          post :create, valid_organization_params
          expect(response).to render_template :new
        end

        it "Should generate error message with illegal email address" do
          params = valid_organization_params
          params[:organization][:members] = "abc\ndef@\n@example.com\nabc@.com\ndef@example"
          post :create, params
          assigns(:verrors).each {|error| expect(error).to match(/Members invalid email address/)}
        end

        it "Should render the new template with illegal email address" do
          params = valid_organization_params
          params[:organization][:members] = "abc\ndef@\n@example.com\nabc@.com\ndef@example"
          post :create, params
          expect(response).to render_template :new
        end
      end

    end

    describe "Authorization examples" do
      it "Return success for a organization owned by the user" do
        login_as_organization_owner
        post :create, valid_organization_params
        expect(response).to redirect_to organization_url(assigns(:organization))
      end

      it "New organization should be owned by the user" do
        login_as_organization_owner
        post :create, valid_organization_params
        expect(assigns(:organization).owner_id).to eq(@owner.id)
      end

      it "Should redirect, if not logged in" do
        sign_out @signed_in_user
        post :create, valid_organization_params
        expect(response).to redirect_to new_user_session_url
      end
    end # Create authorization examples
  end

  # UPDATE ACTION TESTS ------------------------------------------------

  describe "PUT update" do
    let(:new_name) {"New Organization Name"}
    let(:new_desc) {"New organization description"}
    let(:new_members) {"123@example.com\n456@example.com\n789@example.com\n"}

    let(:update_params){
      { id: @organization.id,
        organization:
        {
          name: new_name,
          description: new_desc,
          members: new_members
        }
      }
    }

    describe "as a customer and organization owner" do

      it "Should redirect to Organization#show path" do
        put :update, update_params
        expect(response).to redirect_to organization_url(@organization)
      end

      it "Should find the correct organization record" do
        put :update, update_params
        expect(assigns(:organization).id).to eq(@organization.id)
      end

      it "Should update organization with description" do
        put :update, update_params
        expect(assigns(:organization).description).to eq(new_desc)
      end

      it "Should create new user records for each email address" do
        put :update, update_params
        new_members.split.each do |email|
          expect(assigns(:organization).users.where(email: email).first).to be_present
        end
      end

      it "Should allow us to delete an existing member" do
        member_count = @organization.users.count + new_members.split.count
        put :update, update_params
        expect(assigns(:organization).users.count).to eq(member_count)

        put :update, {
          id: @organization.id,
          organization: { user_ids: ["#{@organization.users.last.id}","#{@organization.users.first.id}"] }
        }
        expect(assigns(:organization).users.count).to eq(member_count - 2)
      end

      it "Should notify each user of their account" do
        put :update, update_params
        ActionMailer::Base.deliveries.each do |delivery|
          expect(new_members).to match(/#{delivery.to}/)
        end
      end

      it "Should relate the correct resources to the organization" do
        create_projects
        project_ids = Project.all.pluck(:id)
        update_params[:organization][:resource_ids] = project_ids
        put :update, update_params
        expect(assigns(:organization).project_ids.sort).to eq(project_ids.sort)
      end

      it "Should relate the correct number of resources to the organization" do
        create_projects
        project_ids = Project.all.pluck(:id)
        update_params[:organization][:resource_ids] = project_ids
        put :update, update_params
        expect(assigns(:organization).projects.count).to eq(project_ids.count)
      end

      context "Invalid update examples" do
        it "Should redirect to sign_in, if not logged in" do
          sign_out @signed_in_user
          put :update, update_params
          expect(response).to redirect_to new_user_session_url
        end

        it "Should redirect to admin_oops_url if user not found" do
          params = update_params
          params[:id] = '99999'
          put :update, params
          expect(response).to redirect_to admin_oops_url
        end

        it "Should flash error message, if organization not found" do
          params = update_params
          params[:id] = '99999'
          put :update, params
          expect(flash[:alert]).to match(/We are unable to find the requested Organization/)
        end

        it "Should render the edit template, if organization could not save" do

          # Setup a method stub for the organization method save
          # to return nil, which indicates a failure to save the account
          allow_any_instance_of(Organization).to receive(:update_attributes).and_return(nil)

          post :update, update_params
          expect(response).to render_template :edit
        end

        it "Should generate error message with illegal email address" do
          params = update_params
          params[:organization][:members] = "abc\ndef@\n@example.com\nabc@.com\ndef@example"
          post :update, params
          assigns(:verrors).each {|error| expect(error).to match(/Members invalid email address/)}
        end

        it "Should render the new template with illegal email address" do
          params = update_params
          params[:organization][:members] = "abc\ndef@\n@example.com\nabc@.com\ndef@example"
          post :update, params
          expect(response).to render_template :edit
        end

      end

    end # Valid update examples


    describe "Authorization examples" do
      let(:set_organization_owner) {
        @organization.owner_id = @owner.id
        @organization.save
      }

      it "Return success for a organization owned by the user" do
        login_as_organization_owner
        set_organization_owner
        put :update, update_params
        expect(response).to redirect_to organization_url(@organization)
      end

      it "Find the requested organization owned by the user" do
        login_as_organization_owner
        set_organization_owner
        put :update, update_params
        expect(assigns(:organization).id).to eq(@organization.id)
      end

      it "Organization owner_id should match requested organization owner_id" do
        login_as_organization_owner
        set_organization_owner
        put :update, update_params
        expect(assigns(:organization).owner_id).to eq(@owner.id)
      end

      it "Return success for a organization with different owner than admin" do
        login_admin
        set_organization_owner
        put :update, update_params
        expect(response).to redirect_to organization_url(@organization)
      end

      it "Find the requested organization with different owner than admin" do
        login_admin
        set_organization_owner
        put :update, update_params
        expect(assigns(:organization).id).to eq(@organization.id)
      end

      it "Organization should have different owner than admin" do
        login_admin
        set_organization_owner
        put :update, update_params
        expect(assigns(:organization).owner_id).not_to eq(@signed_in_user.id)
      end

      it "Redirect to admin_oops for a organization NOT owned by the user" do
        login_nonowner
        put :update, update_params
        expect(response).to redirect_to admin_oops_url
      end

      it "Flash alert message for a organization NOT owned by the user" do
        login_nonowner
        put :update, update_params
        expect(flash[:alert]).to match(/You are not authorized to access the requested #{@organization.class}/)
      end
    end # Update authorization examples
  end

  # DELETE ACTION CREATE -----------------------------------------------

  describe "DELETE destroy" do
    let(:destroy_params) {
      {
        id: @organization.id
      }
    }

    describe "Valid examples" do
      it "Should redirect to #index" do
        delete :destroy, destroy_params
        expect(response).to redirect_to organizations_url
      end

      it "Should display a success message" do
        delete :destroy, destroy_params
        expect(flash[:notice]).to match(/Organization was successfully deleted./)
      end

      it "Should delete account record" do
        expect{
          delete :destroy, destroy_params
        }.to change(Organization, :count).by(-1)
      end

      it "Should unrelate all organization resources" do
        # Associate resources to the organization
        project = FactoryGirl.create(:project, user: @signed_in_user)
        @organization.projects << project

        rcount = Project.count
        expect(rcount).not_to eq(0)

        expect{
          delete :destroy, destroy_params
        }.to change(Project, :count).by(0)

        expect(Project.count).to eq(rcount)
      end
    end # Valid examples

    describe "Invalid examples" do
      it "Should redirect to sign_in, if not logged in" do
        sign_out @signed_in_user
        delete :destroy, destroy_params
        expect(response).to redirect_to new_user_session_url
      end

      it "Should redirect to users#index, if no organization record found" do
        params = destroy_params
        params[:id] = '00999'
        delete :destroy, params
        expect(response).to redirect_to admin_oops_url
      end

      it "Should flash an error message, if no organization record found" do
        params = destroy_params
        params[:id] = '00999'
        delete :destroy, params
        expect(flash[:alert]).to match(/We are unable to find the requested Organization/)
      end
    end # Invalid examples

    describe "Authorization examples" do
      it "Should redirect to organizations_url, upon succesfull deletion of owned organization" do
        delete :destroy, destroy_params
        expect(response).to redirect_to organizations_url
      end

      it "Deleted organization should have same owner id as login" do
        delete :destroy, destroy_params
        expect(assigns(:organization).owner_id).to eq(@signed_in_user.id)
      end

      it "Should redirect to organizations_url, upon successful deletion of organization as admin" do
        login_admin
        delete :destroy, destroy_params
        expect(response).to redirect_to organizations_url
      end

      it "Deleted organization should have different owner id from admin" do
        login_admin
        delete :destroy, destroy_params
        expect(assigns(:organization).owner_id).not_to eq(@signed_in_user.id)
      end

      it "Should redirect to admin oops for non-owner access" do
        login_nonowner
        delete :destroy, destroy_params
        expect(response).to redirect_to admin_oops_url
      end

      it "Should flash alert for non-owner access" do
        login_nonowner
        delete :destroy, destroy_params
        expect(flash[:alert]).to match(/You are not authorized to access the requested #{@organization.class}/)
      end
    end # Authorization examples for delete
  end

  # NOTIFY ACTION TESTS ------------------------------------------------

  describe "Notify tests" do
    let(:notify_params) {
      {
        id: @organization.id,
        uid: @organization.users.last.id
      }
    }

    describe "as owner of the organization" do
      it "Should redirect to organization_url" do
        put :notify, notify_params
        expect(response).to redirect_to organization_url(assigns(:organization))
      end

      it "Should find the matching organization" do
        put :notify, notify_params
        expect(assigns(:organization).id).to eq(@organization.id)
      end

      it "Should find the matching member user" do
        put :notify, notify_params
        expect(assigns(:user).id).to eq(@organization.users.last.id)
      end

      it "Should notify each user of their account" do
        user = @organization.users.last
        put :notify, notify_params
        expect(user.email).to match (/#{ActionMailer::Base.deliveries.last.to}/)
      end

      describe "Invalid examples" do
        it "Should redirect to sign_in, if not logged in" do
          sign_out @signed_in_user
          put :notify, notify_params
          expect(response).to redirect_to new_user_session_url
        end

        it "Should redirect to admin_oops_url if bad organization id" do
          notify_params[:id] = '99999'
          put :notify, notify_params
          expect(response).to redirect_to admin_oops_url
        end

        it "Should flash an alert message if bad organization id" do
          notify_params[:id] = '99999'
          put :notify, notify_params
          expect(flash[:alert]).to match(/We are unable to find the requested Organization/)
        end

        it "Should redirect to admin_oops_url if bad user id" do
          notify_params[:uid] = '99999'
          put :notify, notify_params
          expect(response).to redirect_to admin_oops_url
        end

        it "Should flash an alert message if bad user id" do
          notify_params[:uid] = '99999'
          put :notify, notify_params
          expect(flash[:alert]).to match(/We are unable to find the requested User/)
        end

        it "Should redirect to organization_url if invite fails" do
          allow_any_instance_of(OrganizationsController).to receive(:invite_member).and_return(nil)
          put :notify, notify_params
          expect(response).to redirect_to organization_url(@organization)
        end

        it "Should flash an alert to organization_url if invite fails" do
          allow_any_instance_of(Organization).to receive(:invite_member).and_return(nil)
          put :notify, notify_params
          expect(flash[:alert]).to match(/Organization invite failed/)
        end
      end # Invalid examples

    end

    describe "Authorization examples" do
      it "Should redirect to organization_url, upon succesfull notification of owned organization" do
        put :notify, notify_params
        expect(response).to redirect_to organization_url(assigns(:organization))
      end

      it "Notified organization should have same owner id as login" do
        put :notify, notify_params
        expect(assigns(:organization).owner_id).to eq(@signed_in_user.id)
      end

      it "Should redirect to organization_url, upon succesfull notification of organization as admin" do
        login_admin
        put :notify, notify_params
        expect(response).to redirect_to organization_url(assigns(:organization))
      end

      it "Notified organization should have different owner id from admin" do
        login_admin
        put :notify, notify_params
        expect(assigns(:organization).owner_id).not_to eq(@signed_in_user.id)
      end

      it "Should redirect to admin oops for non-owner access" do
        login_nonowner
        put :notify, notify_params
        expect(response).to redirect_to admin_oops_url
      end

      it "Should flash alert for non-owner access" do
        login_nonowner
        put :notify, notify_params
        expect(flash[:alert]).to match(/You are not authorized to access the requested #{@organization.class}/)
      end
    end # Authorization examples for notify
  end # Notify

end
