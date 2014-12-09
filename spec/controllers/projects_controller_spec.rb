require 'spec_helper'

describe ProjectsController, :type => :controller do

  include_context 'user_setup'
  include_context 'organization_setup'
  include_context 'project_setup'

  ## TEST SETUP --------------------------------------------------------
  let(:name) {"Sample Project"}
  let(:desc) {"The sample project for testing"}

  let(:project) { Project.where(user_id: @owner.id).first }

   let(:login_nonowner_no_org) {
    sign_out subject.current_user
    sign_in FactoryGirl.create(:user)
  }

  # Not an owner but part of the organization
  let(:login_nonowner_in_org) {
    sign_out subject.current_user

    # Find a user that is part of the org, but not the project creator
    sign_in User.find((@organization.users.pluck(:id).reject {|id| id == project.user.id}).last)
  }

  before(:each) {
    # Setup project with users
    projects_with_users
    create_users

    # Create a organization and make the owner one the project user
    single_organization_with_users

    # Setup project to belong to the organization
    @organization.projects << FactoryGirl.create(:project, user: @owner)
    Project.all.each { |project| @organization.projects << project }

    sign_in @owner
  }

  after(:each) {
    User.delete_all
    Project.delete_all
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

      it "assigns all projects as projects" do
        count = Project.all.count
        count = ApplicationController::PAGE_COUNT if count > ApplicationController::PAGE_COUNT
        get :index
        expect(assigns(:projects).count).to eq(count)
      end
    end

    describe "invalid examples" do
      it "should redirect to sign in, if not signed in" do
  	    sign_out subject.current_user
  	    get :index
  	    expect(response).to redirect_to new_user_session_url
  	  end

  	  it "Should still return success, if no groups present" do
  	    Project.delete_all
  	    get :index
  	    expect(response).to be_success
  	    expect(assigns(:projects).count).to eq(0)
  	  end
    end

    describe "authorization examples" do
      it "Should return success as a customer" do
        get :index
        expect(response).to be_success
      end

      it "Should only access projects that user owns" do
        get :index
        expect(assigns(:projects).count).not_to eq(0)
        assigns(:projects).each do |project|
          expect(project.user.id).to eq(project.user.id)
        end
      end

      it "Should not access any projects, if not project owner and not in organization" do
        login_nonowner_no_org
        get :index
        expect(assigns(:projects).count).to eq(0)
      end

      it "Should access all projects in organization" do
        login_nonowner_in_org
        get :index

        expect(assigns(:projects).count).to be > 0
        assigns(:projects).each do |project|
          expect(project.organization_id).to eq(subject.current_user.organization_id)
        end
      end

      it "Should return all projects, if service admin" do
        login_admin
        get :index
        expect(response).to be_success
        expect(assigns(:projects).count).not_to eq(0)
        expect(assigns(:projects).count).to eq(Project.count)
      end
    end # Index authorization
  end

  ## SHOW TESTS --------------------------------------------------------

  describe "GET show" do
    let(:show_params) {
      { id: project.id }
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

      it "Should find matching project" do
        get :show, show_params
        expect(assigns(:project).id).to eq(project.id)
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
        expect(flash[:alert]).to match(/^We are unable to find the requested Project/)
      end

    end

    describe "Authorization examples" do
      describe "access by owner" do
        it "Return success for a project owned by the user" do
          get :show, show_params
          expect(response).to be_success
        end

        it "Find the requested project owned by the user" do
          get :show, show_params
          expect(assigns(:project).id).to eq(project.id)
        end
      end # access by owner

      describe "access by non-owner and non-organization member" do
        before(:each) { login_nonowner_no_org }

        it "Redirect to admin_oops_url for a project NOT owned by the user" do
          get :show, show_params
          expect(response).to redirect_to admin_oops_url
        end

        it "Flash alert message for a group NOT owned by the user" do
          get :show, show_params
          expect(flash[:alert]).to match(/You are not authorized to access the requested #{project.class}/)
        end
      end  # non-owner access

      describe "access by non-owner but a organization member" do
        before(:each){
          login_nonowner_in_org
        }

        it "Return success for the requested project by the user" do
          get :show, show_params
          expect(response).to be_success
        end

        it "Find the requested project" do
          get :show, show_params
          expect(assigns(:project).id).to eq(project.id)
        end

        it "The requested project should not be owned by the signed user" do
          expect(@organization.users.pluck(:id)).to include(project.user_id)
          get :show, show_params
          expect(assigns(:project).user.id).not_to eq(subject.current_user.id)
        end
      end # non-owner, but group member

      describe "access by admin user" do
        before(:each) { login_admin }

        it "Return success for a project using admin login" do
          get :show, show_params
          expect(response).to be_success
        end

        it "Find the requested project with admin login" do
          get :show, show_params
          expect(assigns(:project).id).to eq(project.id)
        end

        it "Project should have different owner than admin" do
          get :show, show_params
          expect(assigns(:project).user.id).not_to eq(subject.current_user.id)
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

      it "assigns a new project as project" do
        get :new
        expect(assigns(:project)).to be_a_new(Project)
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
     it "Return success for a new project owned by the current_user" do
        get :new
        expect(response).to be_success
        expect(response).to render_template :new
      end

      it "Return success for a new project logged in as admin" do
        login_admin
        get :new
        expect(response).to be_success
        expect(response).to render_template :new
      end
		end # New authorization examples
  end

  ## EDIT TESTS --------------------------------------------------------
  describe "GET edit" do
    let(:edit_params) { {id: project.id} }

    describe "Valid tests" do
      it "Should return success" do
        get :edit, edit_params
        expect(response).to be_success
      end

      it "Should use the edit template" do
        get :edit, edit_params
        expect(response).to render_template :edit
      end

      it "Should find the project record" do
        get :edit, edit_params
        expect(assigns(:project).id).to eq(project.id)
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
        expect(flash[:alert]).to match(/We are unable to find the requested Project/)
      end
		end # Invalid tests

    describe "Authorization examples" do
      describe "access by owner" do
        it "Return success for a project owned by the user" do
          get :edit, edit_params
          expect(response).to be_success
        end

        it "Find the requested project owned by the user" do
          get :edit, edit_params
          expect(assigns(:project).id).to eq(project.id)
        end

        it "Project user.id should match signed_in_user.id" do
          get :edit, edit_params
          expect(assigns(:project).user.id).to eq(subject.current_user.id)
        end
      end # access by owner

      describe "access by non-owner and non-organization member" do
        before(:each) { login_nonowner_no_org }

        it "Redirect to admin_oops_url for a project NOT owned by the user" do
          get :edit, edit_params
          expect(response).to redirect_to admin_oops_url
        end

        it "Flash alert message for a group NOT owned by the user" do
          get :edit, edit_params
          expect(flash[:alert]).to match(/You are not authorized to access the requested #{project.class}/)
        end
      end

      describe "access by non-owner and organization member" do
        before(:each){
          login_nonowner_in_org
        }

        it "Return success for a project by a member user" do
          get :edit, edit_params
          expect(response).to be_success
        end

        it "Find the requested project owned by a member user" do
          get :edit, edit_params
          expect(assigns(:project).id).to eq(project.id)
        end

        it "Project user.id should match signed_in_user.id" do
          expect(@organization.users.pluck(:id)).to include(project.user_id)
          get :edit, edit_params
          expect(assigns(:project).user.id).not_to eq(subject.current_user.id)
        end
      end

      describe "access by admin user" do
        before(:each) { login_admin }

        it "Return success for a project owned by the user" do
          get :edit, edit_params
          expect(response).to be_success
        end

        it "Find the requested project owned by the user" do
          get :edit, edit_params
          expect(assigns(:project).id).to eq(project.id)
        end

        it "Project user.id should match admin_user id" do
          get :edit, edit_params
          expect(assigns(:project).user.id).not_to eq(subject.current_user.id)
        end
      end
    end # Edit authorization examples
  end

  ## CREATE TESTS ------------------------------------------------------

  describe "POST create" do

    let(:project_params){
      {project:
        {
          name: name,
          description: desc,
          organization_id: [@organization.id]
        }
      }
    }

    describe "with valid params" do

      it "creates a new Project" do
        expect {
          post :create, project_params
        }.to change(Project, :count).by(1)
      end

      it "assigns a newly created project as project" do
        post :create, project_params
        expect(assigns(:project)).to be_a(Project)
        expect(assigns(:project)).to be_persisted
      end

      it "redirects to the created project" do
        post :create, project_params
        expect(response).to redirect_to(assigns(:project))
      end

      it "should update project with name" do
        post :create, project_params
        expect(assigns(:project).name).to eq(name)
      end

      it "should update project with description" do
        post :create, project_params
        expect(assigns(:project).description).to eq(desc)
      end

      it "should update the organization relationship" do
        post :create, project_params
        expect(assigns(:project).organization_id).to eq(@organization.id)
      end

      describe "file upload examples" do
        before(:each) do
          @file = fixture_file_upload('spec/fixtures/test_doc.pdf',
            'application/pdf')
          project_params[:project][:charter_doc] = @file
        end

        it "should allow attaching a pdf file" do
          post :create, project_params
          expect(response).to redirect_to(assigns(:project))
        end

        it "should upload file and set file name attribute" do
          post :create, project_params
          expect(assigns(:project).charter_doc_file_name).to match(/test_doc.pdf/)
        end

        it "should upload file and set file url attribute" do
          post :create, project_params
          expect(assigns(:project).charter_doc.url).to match(/test_doc.pdf/)
        end

        it "should upload file and set file content_type attribute" do
          post :create, project_params
          expect(assigns(:project).charter_doc_content_type).to match(/pdf/)
        end
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved project as project" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Project).to receive(:save).and_return(false)
        post :create, {:project => { "name" => "invalid value" }}
        expect(assigns(:project)).to be_a_new(Project)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Project).to receive(:save).and_return(false)
        post :create, {:project => { "name" => "invalid value" }}
        expect(response).to render_template("new")
      end

      it "sets validation errors for missing name" do
        project_params[:project][:name] = nil
        post :create, project_params
        expect(assigns(:verrors)[0]).to match(/Name can't be blank/)
      end

      it "sets validation errors for missing description" do
        project_params[:project][:description] = nil
        post :create, project_params
        expect(assigns(:verrors)[0]).to match(/Description can't be blank/)
      end
    end # invalid params

    describe "Authorization examples" do
      it "should create a project with customer's id" do
        post :create, project_params
        expect(assigns(:project).user.id).to eq(subject.current_user.id)
      end

      it "should create a project with admin user's id" do
        login_admin
        post :create, project_params
        expect(assigns(:project).user.id).to eq(subject.current_user.id)
        expect(assigns(:project).user.role).to eq(User::SERVICE_ADMIN)
      end
    end # Create authorization examples
  end

  ## UPDATE TESTS ------------------------------------------------------

  describe "PUT update" do
   let(:update_params){
      { id: project.id,
        project:
        {
          name: name,
          description: desc,
          organization_id: [@organization.id]
        }
      }
    }

    describe "with valid params" do
      it "Should redirect to Project#show path" do
        put :update, update_params
        expect(response).to redirect_to project_url(project)
      end

      it "Should find the correct project record" do
        put :update, update_params
        expect(assigns(:project).id).to eq(project.id)
      end

      it "Should update project with description" do
        put :update, update_params
        expect(assigns(:project).description).to eq(desc)
      end

      it "Should update the project name" do
        put :update, update_params
        expect(assigns(:project).name).to eq(name)
      end

      it "Should update the organization relation" do
        put :update, update_params
        expect(assigns(:project).organization_id).to eq(@organization.id)
      end

      describe "file upload examples" do
        before(:each) do
          @file = fixture_file_upload('spec/fixtures/test_doc.pdf',
            'application/pdf')
          update_params[:project][:charter_doc] = @file
        end

        it "should allow attaching a pdf file" do
          put :update, update_params
          expect(response).to redirect_to(assigns(:project))
        end

        it "should upload file and set file name attribute" do
          put :update, update_params
          expect(assigns(:project).charter_doc_file_name).to match(/test_doc.pdf/)
        end

        it "should upload file and set file url attribute" do
          put :update, update_params
          expect(assigns(:project).charter_doc.url).to match(/test_doc.pdf/)
        end

        it "should upload file and set file content_type attribute" do
          put :update, update_params
          expect(assigns(:project).charter_doc_content_type).to match(/pdf/)
        end
      end
    end # with valid parameters

    describe "with invalid params" do
      it "Should redirect to sign_in, if not logged in" do
        sign_out subject.current_user
        put :update, update_params
        expect(response).to redirect_to new_user_session_url
      end

      it "Should redirect to admin_oops_url, if user not found" do
        params = update_params
        params[:id] = '99999'
        put :update, params
        expect(response).to redirect_to admin_oops_url
      end

      it "Should flash error message, if group not found" do
        params = update_params
        params[:id] = '99999'
        put :update, params
        expect(flash[:alert]).to match(/We are unable to find the requested Project/)
      end

      it "Should render the edit template, if group could not save" do

        # Setup a method stub for the group method save
        # to return nil, which indicates a failure to save the account
        allow_any_instance_of(Project).to receive(:update_attributes).and_return(nil)

        post :update, update_params
        expect(response).to render_template :edit
      end
    end # invalid examples

    describe "Authorization tests" do
      describe "with access by owner" do
        it "Redirect to project_url for a project owned by the user" do
          get :update, update_params
          expect(response).to redirect_to project_url(project)
        end

        it "Find the requested project owned by the user" do
          get :update, update_params
          expect(assigns(:project).id).to eq(project.id)
        end

        it "Project user.id should match signed_in_user.id" do
          get :update, update_params
          expect(assigns(:project).user.id).to eq(subject.current_user.id)
        end
      end # access by owner

      describe "access by non-owner and non-organization member" do
        before(:each) { login_nonowner_no_org }

        it "Redirect to admin_oops_url for a project NOT owned by the user" do
          get :update, update_params
          expect(response).to redirect_to admin_oops_url
        end

        it "Flash alert message for a group NOT owned by the user" do
          get :update, update_params
          expect(flash[:alert]).to match(/You are not authorized to access the requested #{project.class}/)
        end
      end

      describe "access by non-owner and organization member" do
        before(:each){
          login_nonowner_in_org
        }

        it "Redirect to project_url for a project by a member user" do
          get :update, update_params
          expect(response).to redirect_to project_url(project)
        end

        it "Find the requested project owned by a member user" do
          get :update, update_params
          expect(assigns(:project).id).to eq(project.id)
        end

        it "Project user.id should match signed_in_user.id" do
          get :update, update_params
          expect(assigns(:project).user.id).not_to eq(subject.current_user.id)
        end

        it "Project organization.id should match signed_in_user.organization.id" do
          get :update, update_params
          expect(assigns(:project).organization.id).to eq(subject.current_user.organization.id)
        end
      end

      describe "access by admin user" do
        before(:each) { login_admin }

        it "Redirect to project_url for a project owned by the user" do
          get :update, update_params
          expect(response).to redirect_to project_url(project)
        end

        it "Find the requested project owned by the user" do
          get :update, update_params
          expect(assigns(:project).id).to eq(project.id)
        end

        it "Project user.id should match admin_user id" do
          get :update, update_params
          expect(assigns(:project).user.id).not_to eq(subject.current_user.id)
        end
      end
    end # Update authorization examples
  end

  ## DESTROY TESTS -----------------------------------------------------

  describe "DELETE destroy" do
    let(:destroy_params) {
      {
        id: project.id
      }
    }

    describe "Valid examples" do
      it "Should redirect to #index" do
        delete :destroy, destroy_params
        expect(response).to redirect_to projects_url
      end

      it "Should display a success message" do
        delete :destroy, destroy_params
        expect(flash[:notice]).to match(/Project was successfully deleted./)
      end

      it "Should delete project record" do
        expect{
          delete :destroy, destroy_params
        }.to change(Project, :count).by(-1)
      end

      it "Should should not destroy any related organziations" do
        org_count = Organization.count
        expect(org_count).not_to eq(0)
        expect {
          delete :destroy, destroy_params
        }.to_not change(Organization, :count).by(-1)
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
        expect(flash[:alert]).to match(/We are unable to find the requested Project/)
      end
    end # Invalid examples

    describe "Authorization examples" do
      describe "with access by owner" do
        it "Should redirect to projects_url, upon succesfull deletion of owned group" do
          delete :destroy, destroy_params
          expect(response).to redirect_to projects_url
        end

        it "Deleted project should have same owner id as login" do
          delete :destroy, destroy_params
          expect(assigns(:project).user.id).to eq(subject.current_user.id)
        end

        it "Should reduce the number of Project records by 1" do
          expect{
            delete :destroy, destroy_params
          }.to change(Project, :count).by(-1)
        end
      end

      describe "access by non-owner and non-group member" do
        before(:each) { login_nonowner_no_org }

        it "Redirect to admin_oops_url for a project NOT owned by the user" do
          delete :destroy, destroy_params
          expect(response).to redirect_to admin_oops_url
        end

        it "Flash alert message for a group NOT owned by the user" do
          delete :destroy, destroy_params
          expect(flash[:alert]).to match(/You are not authorized to access the requested #{project.class}/)
        end

        it "Should not delete a Project record" do
          expect {
            delete :destroy, destroy_params
          }.to change(Project, :count).by(0)
        end
      end

      describe "access by non-owner and in organization" do
        before(:each){
          login_nonowner_in_org
        }

        it "Should redirect to projects_url, upon successful deletion" do
          delete :destroy, destroy_params
          expect(response).to redirect_to projects_url
        end

        it "Deleted project should NOT have same owner id as login" do
          delete :destroy, destroy_params
          expect(assigns(:project).user.id).not_to eq(subject.current_user.id)
        end

        it "Deleted project should have same organization_id as user" do
          delete :destroy, destroy_params
          expect(assigns(:project).organization.id).to eq(subject.current_user.organization.id)
        end

        it "Should reduce the number of Project records by 1" do
          expect{
            delete :destroy, destroy_params
          }.to change(Project, :count).by(-1)
        end

        it "Should reduce the number of organizations" do
          org_count = Organization.count
          expect{
            delete :destroy, destroy_params
          }.to_not change(Organization, :count).by(-1)
        end
      end

      describe "as a service admin" do
        before(:each) { login_admin }

        it "Should redirect to projects_url, upon succesfull deletion of owned group" do
          delete :destroy, destroy_params
          expect(response).to redirect_to projects_url
        end

        it "Should reduce the number of Project records by 1" do
          expect{
            delete :destroy, destroy_params
          }.to change(Project, :count).by(-1)
        end

        it "Deleted project should have different owner id from admin" do
          delete :destroy, destroy_params
          expect(assigns(:project).user.id).not_to eq(subject.current_user.id)
        end
      end # service admin

    end # Authorization examples for delete
  end # delete examples

end
