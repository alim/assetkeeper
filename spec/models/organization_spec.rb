require 'spec_helper'

describe Organization, :type => :model do
  include_context 'user_setup'
  include_context 'organization_setup'

  # SETUP --------------------------------------------------------------
  let(:one_organization) {
    multiple_organizations
    Organization.last
  }

  after(:each) {
    Organization.destroy_all
    User.destroy_all
  }

  # ATTRIBUTE TESTS ----------------------------------------------------
  describe 'Attribute tests' do
    it { is_expected.to respond_to(:name) }
		it { is_expected.to respond_to(:description) }
		it { is_expected.to respond_to(:owner) }
  end

  # VALIDATION TESTS ---------------------------------------------------
  describe 'Validation tests' do
    it 'Should be valid with all fields' do
      expect(one_organization).to be_valid
    end

    it 'Should not be valid without a name' do
      one_organization.name = nil
      expect(one_organization).not_to be_valid
    end

    it 'Should not be valid without a description' do
      one_organization.description = nil
      expect(one_organization).not_to be_valid
    end

    it 'Should not be valid without an owner' do
      one_organization.owner = nil
      expect(one_organization).not_to be_valid
    end
  end

  # MEMBERSHIP TESTS ---------------------------------------------------
  describe 'Organization membership email list tests' do
    let(:email_list) {
      'abc@example.com\ndef@example.com\tghi@example.com jkl@example.com'
    }

    let(:invalid_email_list) {
      "abc\ndef@example\t@example.com jkl@.com"
    }

    it 'Should store a list of white space delimited email addresses' do
      one_organization.members = email_list
      expect(one_organization).to be_valid
      expect(one_organization.members).to eq(email_list)
    end

    it 'Should not be valid, with invalid email list' do
      one_organization.members = invalid_email_list
      expect(one_organization).not_to be_valid
      expect(one_organization.members).to eq(invalid_email_list)
    end

    it 'Should log errors for each invalid email address' do
      one_organization.members = invalid_email_list
      expect(one_organization).not_to be_valid
      email = invalid_email_list.gsub(/\s+/, ' ').split
      i = 0
      one_organization.errors.full_messages.each do |message|
        expect(message).to match(/#{email[i]}/)
        i += 1
      end
      expect(i).to eq(email.count)
    end
  end

  # RELATIONSHIP TESTS -------------------------------------------
  describe 'Organization relationship testing' do
    describe 'Single organization with multiple users' do
      before(:each) {
        single_organization_with_users
        @organization = Organization.first
      }

      it 'Should allow access to each user email' do
        expect(@organization.users.count).to eq(5)
        @organization.users.each { |user| expect(user.email).to be_present }
      end

      it 'Should allow access to each user first_name' do
        expect(@organization.users.count).to eq(5)
        @organization.users.each { |user| expect(user.first_name).to be_present }
      end

      it 'Should allow access to each user last_name' do
        expect(@organization.users.count).to eq(5)
        @organization.users.each { |user| expect(user.last_name).to be_present }
      end

      it 'Should allow access to the organization name from each user' do
        User.all.each do |user|
          expect(user.organization.name).to be_present
          expect(user.organization.id).to eq(@organization.id)
        end
      end

      it 'Should allow access to the organization description from each user' do
        User.all.each do |user|
          expect(user.organization.description).to be_present
          expect(user.organization.id).to eq(@organization.id)
        end
      end
    end # Single organization with multiple users

  end # Organization relationships

  # ORGANIZATION USER TESTS -------------------------------------------

  describe 'create and notify tests' do
    let(:new_members) { 'roger_rabbit@warner.com   jessica_rabbit@warner.com' }
    before(:each) {
      ActionMailer::Base.deliveries.clear
      single_organization_with_users
    }

    after(:each) { ActionMailer::Base.deliveries.clear }

    it 'should add users to the organization' do
      @organization.members = new_members
      @organization.create_notify
      @organization.users.count == 7

      new_members.split {|e| expect(User.where(email: e)).not_to be_empty }
    end

    it 'should create an email for each new user' do
      @organization.members = new_members
      @organization.create_notify
      expect(ActionMailer::Base.deliveries.count).to eq(2)
    end

    it 'should create an email messages with the right fields' do
      @organization.members = new_members
      @organization.create_notify

      ActionMailer::Base.deliveries.each do |d|
        expect(new_members.split).to include(d.to[0])
        expect(d.from[0]).to match(/no-reply/)
        expect(d.subject).to match(/has added you to their organization.$/)
      end
    end

    it 'should return nil, if no members' do
      @organization.members = ''
      expect(@organization.create_notify).to be_nil
    end

    it 'should not send any emails, if no members' do
      @organization.members = ''
      @organization.create_notify
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end

    it 'should not notify existing users' do
      current_users = @organization.users.pluck(:email)
      @organization.members = new_members
      @organization.create_notify

      ActionMailer::Base.deliveries.each do |d|
        expect(current_users.split).not_to include(d.to[0])
      end
    end
  end

  describe 'invite user tests' do
    before(:each) {
      ActionMailer::Base.deliveries.clear
      single_organization_with_users
    }
    after(:each) { ActionMailer::Base.deliveries.clear }

    it 'should create an email for the invited user' do
      @organization.invite_member(@organization.users.last)
      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end

    it 'should address it to the write person' do
      @organization.invite_member(@organization.users.last)
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first.to[0]).to eq(@organization.users.last.email)
    end

    it 'should have a password set' do
      @organization.invite_member(@organization.users.last)
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first.encoded).to match(/password:/)
    end
  end

  # RELATE CLASSES ----------------------------------------------------
  pending '#relate_classes' do
    before(:each) {
      single_organization_with_users
      10.times.each { FactoryGirl.create(:project, user: @owner)}
    }

    it 'should set the organization of managed projects' do
      Project.all.each do |project|
        expect(project.organization).to be_nil
      end
      @organization.relate_classes
      expect(@organization.projects.count).to be > 0
      Project.all.each { |project| expect(project.organization).to eq(@organization) }
    end

    it 'should not relate projects not created by organization owner' do
      user = FactoryGirl.create(:user)

      Project.all.each do |project|
        project.user = user
        project.save
      end

      @organization.relate_classes
      expect(@organization.projects.count).to eq(0)
    end

  end

  ## MANAGE CLASSES ---------------------------------------------------

  pending '#managed_classes' do
    before(:each) {
      single_organization_with_users
      10.times.each { FactoryGirl.create(:project, user: @owner)}
    }

    it 'should find all instances of a related class' do
      Project.all.each do |project|
        project.organization = @organization
        project.save
      end

      mclasses = @organization.managed_classes
      mclasses[:project].each do |project|
        expect(project.organization).to eq(@organization)
      end
    end

  end

  ## UNRELATE CLASSES -------------------------------------------------

  pending '#unrelate_classes' do
    let(:setup_projects) {
      Project.all.each do |project|
        expect(project.organization).to be_nil
      end
    }
    before(:each) {
      single_organization_with_users
      10.times.each { FactoryGirl.create(:project, user: @owner)}
    }

    it 'should un-relate project classes' do
      setup_projects
      @organization.relate_classes
      expect(@organization.projects.count).to be > 0
      Project.all.each { |project| expect(project.organization).to eq(@organization) }
      @organization.unrelate_classes
      expect(@organization.projects.count).to eq(0)
      expect(Project.count).to be > 0
    end
  end

  ## CREATE WITH OWNER ------------------------------------------------

  describe '#create_with_owner' do
    let(:owner){ FactoryGirl.create(:user) }

    let(:name) {'Sample Organization'}
    let(:desc) {'The sample organization for testing'}
    let(:members) {'one@example.com\ntwo@example.com\nthree@example.com\n'}

    let(:org_params) do
      {
        name: name,
        description: desc,
        members: members
      }
    end

    it 'should create a new Organization' do
      expect {
        Organization.create_with_owner(org_params, owner).save
      }.to change(Organization, :count).by(1)
    end

    it 'should relate the organization to the correct user' do
      org = Organization.create_with_owner(org_params, owner)
      expect(org.owner).to eq(owner)
      expect(owner.organization).to eq(org)
    end
  end
end
