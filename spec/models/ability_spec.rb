require "spec_helper"
require "cancan/matchers"

describe Ability, :type => :model do
  include_context 'user_setup'
  include_context 'subscription_setup'
  include_context 'manufacturer_setup'
  include_context 'organization_setup'

  let(:customer) { FactoryGirl.create(:user) }
  let(:account_customer) { FactoryGirl.create(:user_with_account) }
  let(:another_customer) { FactoryGirl.create(:user_with_account) }
  let(:admin) { FactoryGirl.create(:adminuser) }

  after do
    Organization.destroy_all
    User.destroy_all
  end

  describe "Standard customer user" do
    subject(:ability) { Ability.new(account_customer) }

    describe "User access" do
      it { is_expected.to be_able_to(:show, account_customer) }
      it { is_expected.to be_able_to(:update, account_customer) }
      it { is_expected.to be_able_to(:destroy, account_customer) }
    end

    describe "Account access" do
      let(:account) { account_customer.account }

      it {is_expected.to be_able_to(:create, account)}
      it {is_expected.to be_able_to(:read, account)}
      it {is_expected.to be_able_to(:update, account)}
      it {is_expected.to be_able_to(:destroy, account)}

      context "with a different user" do
        let(:account) { another_customer.account }

        it {is_expected.not_to be_able_to(:create, account)}
        it {is_expected.not_to be_able_to(:read, account)}
        it {is_expected.not_to be_able_to(:update, account)}
        it {is_expected.not_to be_able_to(:destroy, account)}
      end
    end

    describe "Organization access" do
      let(:organization) { FactoryGirl.create(:organization, owner: account_customer) }

      it {is_expected.to be_able_to(:create, organization)}
      it {is_expected.to be_able_to(:read, organization)}
      it {is_expected.to be_able_to(:update, organization)}
      it {is_expected.to be_able_to(:destroy, organization)}

      describe "different owner" do
        let(:organization) { FactoryGirl.create(:organization, owner: another_customer) }

        it {is_expected.not_to be_able_to(:create, organization)}
        it {is_expected.not_to be_able_to(:read, organization)}
        it {is_expected.not_to be_able_to(:update, organization)}
        it {is_expected.not_to be_able_to(:destroy, organization)}
      end

      describe 'organization member access' do
        before do
          single_organization_with_users
          @org_member = @organization.users.where(:id.ne => @organization.owner.id).first
        end

        subject(:ability) { Ability.new(@org_member)}

        it {is_expected.to be_able_to(:read, @organization)}
        it {is_expected.not_to be_able_to(:create, @organization)}
        it {is_expected.not_to be_able_to(:update, @organization)}
        it {is_expected.not_to be_able_to(:destroy, @organization)}
      end
    end

    describe "Asset access" do
      let(:asset) { FactoryGirl.create(:asset_item, user: account_customer) }
      let(:org) { FactoryGirl.create(:organization, owner: account_customer ) }

      before(:each) {
        account_customer.organization = org
        asset.organization = org
      }

      it {is_expected.to be_able_to(:read, asset)}
      it {is_expected.to be_able_to(:create, asset)}
      it {is_expected.to be_able_to(:update, asset)}
      it {is_expected.to be_able_to(:destroy, asset)}

      context "different owner" do
        let(:asset) { FactoryGirl.create(:asset_item, user: another_customer) }
        let(:org) { FactoryGirl.create(:organization, owner: another_customer) }
        before(:each) { account_customer.organization = nil }

        it {is_expected.not_to be_able_to(:create, asset)}
        it {is_expected.not_to be_able_to(:read, asset)}
        it {is_expected.not_to be_able_to(:update, asset)}
        it {is_expected.not_to be_able_to(:destroy, asset)}
      end
    end

    describe "Subscription Access Tests" do

      # Create a normal user
      let(:normal_user) { FactoryGirl.create(:user) }

      # Create a abnormal user
      let(:abnormal_user) { FactoryGirl.create(:user) }

      # Create a single fake subscription owned by a single user
      let(:subscription_fake_customer) {
        FactoryGirl.create(:subscription, user: normal_user)
      }

      # Create a single fake subscription owned by a single abnormal user
      let(:subscription_fake_abnormal_customer) {
        FactoryGirl.create(:subscription, user: abnormal_user)
      }

      # Subscription Admin Tests with CRUD access rights
      describe "Subscription Admin Access Tests" do

        sub_admin = FactoryGirl.create(:adminuser)
        subject(:admin_ability) { Ability.new(sub_admin) }

        it "Create a Subscription" do
          is_expected.to be_able_to(:create, subscription_fake_customer)
        end

        it "Read a Subscription" do
          is_expected.to be_able_to(:read, subscription_fake_customer)
        end

        it "Update a Subscription" do
          is_expected.to be_able_to(:update, subscription_fake_customer)
        end

        it "Delete a Subscription" do
          is_expected.to be_able_to(:destroy, subscription_fake_customer)
        end
      end

      # Subscription User Tests with CRUD access rights
      describe "Subscription User Access Tests" do

        subject(:user_ability) { Ability.new(normal_user) }

        it "Create a Subscription" do
          is_expected.to be_able_to(:create, subscription_fake_customer)
        end

        it "Read a Subscription" do
          is_expected.to be_able_to(:read, subscription_fake_customer)
        end

        it "Update a Subscription" do
          is_expected.to be_able_to(:update, subscription_fake_customer)
        end

        it "Delete a Subscription" do
          is_expected.to be_able_to(:destroy, subscription_fake_customer)
        end
      end

      # Subscription User Tests with Non CRUD access rights
      describe "Subscription Non User Access Tests" do

        it "Create a Subscription" do
          is_expected.not_to be_able_to(:create, subscription_fake_abnormal_customer)
        end

        it "Read a Subscription" do
          is_expected.not_to be_able_to(:read, subscription_fake_abnormal_customer)
        end

        it "Update a Subscription" do
          is_expected.not_to be_able_to(:update, subscription_fake_abnormal_customer)
        end

        it "Delete a Subscription" do
          is_expected.not_to be_able_to(:destroy, subscription_fake_abnormal_customer)
        end
      end
    end
    describe "Manufacturer Access Tests" do
      # CREATE A SINGLE MANUFACTURER -------------------------------------------

      let(:fake_manufacturer) {
       FactoryGirl.create(:manufacturer)
      }

       # Manufacturer Admin Tests with CRUD access rights

      describe "Manufacturer Admin Access Tests" do

        manu_admin = FactoryGirl.create(:adminuser)

        subject(:admin_ability) { Ability.new(manu_admin) }

        it "Create a Manufacturer" do
          is_expected.to be_able_to(:create, fake_manufacturer)
        end

        it "Read a Manufacturer" do
          is_expected.to be_able_to(:read, fake_manufacturer)
        end

        it "Update a Manufacturer" do
          is_expected.to be_able_to(:update, fake_manufacturer)
        end

        it "Delete a Manufacturer" do
          is_expected.to be_able_to(:destroy, fake_manufacturer)
        end
      end

        # Manufacturer User Tests with CRUD access rights

      describe "Manufacturer Non User Access Tests" do

        manu_non_admin = FactoryGirl.create(:user)

        subject(:user_ability) { Ability.new(manu_non_admin) }

        it "Create a Manufacturer" do
          is_expected.not_to be_able_to(:create, fake_manufacturer)
        end

        it "Read a Manufacturer" do
          is_expected.to be_able_to(:read, fake_manufacturer)
        end

        it "Update a Manufacturer" do
          is_expected.not_to be_able_to(:update, fake_manufacturer)
        end

        it "Delete a Manufacturer" do
          is_expected.not_to be_able_to(:destroy, fake_manufacturer)
        end
      end
    end
  end
end
