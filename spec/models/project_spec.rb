require 'spec_helper'

describe Project, :type => :model do
  include_context 'project_setup'

  let(:a_project) { Project.where(:user_id.exists => true).first }

  before(:each) {
    projects_with_users
  }

  after(:each) {
    User.delete_all
    Project.delete_all
    Organization.delete_all
  }

  ## METHOD CHECKS -----------------------------------------------------
	describe "Should respond to all accessor methods" do
		it { is_expected.to respond_to(:name) }
		it { is_expected.to respond_to(:description) }
		it { is_expected.to respond_to(:user_id) }
		it { is_expected.to respond_to(:organization_id) }
	end

	## VALIDATION CHECKS -------------------------------------------------
	describe "Validation checks" do
	  describe "Valid tests" do
	    it "Should be valid with a user and NO organization" do
	      expect(a_project).to be_valid
	    end
	  end

	  describe "Invalid tests" do
	    it "Should be invalid without a name" do
        project = a_project
	      project.name = nil
	      expect(project).not_to be_valid
	    end

	    it "Should be invalid without a description" do
        project = a_project
	      project.description = nil
	      expect(project).not_to be_valid
	    end

	    it "Should be invalid without a user_id" do
	      project = FactoryGirl.build(:project)
	      expect(project).not_to be_valid
	    end

	    it "Project should be destroyed, if user is destroyed" do
        project = a_project
	      user = project.user
	      user.destroy
	      expect{
	        project.reload
	      }.to raise_error(Mongoid::Errors::DocumentNotFound)
	    end
	  end

    describe "Organizational concern tests" do

      describe "scope tests" do
        let(:new_user) { FactoryGirl.create(:user) }
        let(:other_project) { FactoryGirl.create(:project, user: new_user) }
        before(:each){
          other_project
        }

        it "should find projects with matching user, but no organization" do
          projects = Project.in_organization(a_project.user)
          projects.each do |project|
            expect(project.user_id).to eq(a_project.user.id)
            expect(project.organization).to be_nil
          end

          expect(projects.count).to be <  Project.count
        end

        it "should find a subset of the projects" do
          projects = Project.in_organization(a_project.user)
          expect(projects.count).to be > 0
          expect(projects.count).to be <  Project.count
        end

        it "should find all projects part of the user's organization" do
          # Create projects with different owners and
          5.times { other_project }
          owner = User.last
          org = FactoryGirl.create(:organization, owner: owner)

          # Find projects not matching owner
          projects = Project.ne(user_id: owner.id)
          expect(projects.count).to be > 0

          # Add projects to organization
          org.projects << projects

          # user_projects = Project.where(user_id: @project.user_id)
          found_projects = Project.in_organization(projects.last.user)

          expect(found_projects.count).to be > 0

          found_projects.each do |project|
            expect(project.organization.id).to eq(org.id)
            expect(project.organization.id).not_to be_nil
            expect(project.user).not_to eq owner
          end
        end
      end

      describe "relate_to_organization tests" do
        let(:org_owner){ FactoryGirl.create(:user) }
        let(:org){ FactoryGirl.create(:organization, owner: org_owner) }
        let(:a_user){ FactoryGirl.create(:user) }

        it "should not relate project to an organization if user doesn't belong to one" do
          expect(a_project.organization).to be_nil
          a_project.relate_to_organization
          expect(a_project.organization).to be_nil
        end

        it "should relate project to a user's organization" do
          org.users << a_user
          a_project.user = a_user
          expect(a_project.organization).to be_nil

          a_project.relate_to_organization
          expect(a_project.organization).to eq(org)
        end
      end
    end
	end

  describe "#create_with_user" do
    let(:new_user){ FactoryGirl.create(:user) }

    let(:project_params) do
      {
        name: 'some name',
        description: 'some description',
      }
    end

    it "should create a new project" do
      expect {
        Project.create_with_user(project_params, new_user).save
      }.to change(Project, :count).by(1)
    end

    it "should relate the project to the correct user" do
      project = Project.create_with_user(project_params, new_user)
      expect(project.user).to eq(new_user)
    end
  end

end
