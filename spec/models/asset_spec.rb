require 'spec_helper'

RSpec.describe Asset, :type => :model do
  include_context 'asset_setup'

  before(:each) {
    assets_with_users
  }

  after(:each) {
    User.delete_all
    Asset.delete_all
    Organization.delete_all
  }

  ## METHOD CHECKS ----------------------------------------------------
  describe "Should respond to all accessor methods" do
    it { is_expected.to respond_to(:name) }
    it { is_expected.to respond_to(:description) }
    it { is_expected.to respond_to(:user_id) }
    it { is_expected.to respond_to(:organization_id) }
    it { is_expected.to respond_to(:location) }
    it { is_expected.to respond_to(:latitude) }
    it { is_expected.to respond_to(:material) }
    it { is_expected.to respond_to(:date_installed) }
    it { is_expected.to respond_to(:condition) }
    it { is_expected.to respond_to(:failure_probablity) }
    it { is_expected.to respond_to(:failure_consequence) }
    it { is_expected.to respond_to(:status) }
  end

  ## VALIDATION CHECKS -------------------------------------------------
  describe "Validation checks" do
    describe "Valid tests" do
      it "Should be valid with a user and NO organization" do
        expect(@asset).to be_valid
      end
    end

    describe "Invalid tests" do
      it "Should be invalid without a name" do
        @asset.name = nil
        expect(@asset).not_to be_valid
      end

      it "Should be invalid without a description" do
        @asset.description = nil
        expect(@asset).not_to be_valid
      end

      it "Should be invalid without a material" do
        @asset.material = nil
        expect(@asset).not_to be_valid
      end

      it "Should be invalid without a condition" do
        @asset.condition = nil
        expect(@asset).not_to be_valid
      end

      it "Should be invalid without a failure_probablity" do
        @asset.failure_probablity = nil
        expect(@asset).not_to be_valid
      end

      it "Should be invalid without a failure_consequence" do
        @asset.failure_consequence = nil
        expect(@asset).not_to be_valid
      end

      it "Should be invalid without a status" do
        @asset.status = nil
        expect(@asset).not_to be_valid
      end

      it "Should be invalid without a user_id" do
        asset = FactoryGirl.build(:asset)
        expect(asset).not_to be_valid
      end

      it "asset should be destroyed, if user is destroyed" do
        user = @asset.user
        user.destroy
        expect{
          @asset.reload
        }.to raise_error(Mongoid::Errors::DocumentNotFound)
      end
    end
  end

  ## ORGANIZATIONAL CONCERN -------------------------------------------

  describe "Organizational concern tests" do

    describe "scope tests" do
      let(:new_user) { FactoryGirl.create(:user) }
      let(:other_asset) { FactoryGirl.create(:asset, user: new_user) }
      before(:each){
        other_asset
      }

      it "should find assets with matching user, but no organization" do
        assets = Asset.in_organization(@asset.user)
        assets.each do |asset|
          expect(asset.user_id).to eq(@asset.user.id)
          expect(asset.organization).to be_nil
        end

        expect(assets.count).to be <  Asset.count
      end

      it "should find a subset of the assets" do
        assets = Asset.in_organization(@asset.user)
        expect(assets.count).to be > 0
        expect(assets.count).to be <  Asset.count
      end

      it "should find all assets part of the user's organization" do
        # Create assets with different owners and
        5.times { other_asset }
        owner = User.last
        org = FactoryGirl.create(:organization, owner: owner)

        # Find assets not matching owner
        assets = Asset.ne(user_id: owner.id)
        expect(assets.count).to be > 0

        # Add assets to organization
        org.assets << assets

        # user_assets = asset.where(user_id: @asset.user_id)
        found_assets = Asset.in_organization(assets.last.user)

        expect(found_assets.count).to be > 0

        found_assets.each do |asset|
          expect(asset.organization.id).to eq(org.id)
          expect(asset.organization.id).not_to be_nil
          expect(asset.user).not_to eq owner
        end
      end
    end

    describe "relate_to_organization tests" do
      let(:org_owner){ FactoryGirl.create(:user) }
      let(:org){ FactoryGirl.create(:organization, owner: org_owner) }
      let(:a_user){ FactoryGirl.create(:user) }

      it "should not relate asset to an organization if user doesn't belong to one" do
        expect(@asset.organization).to be_nil
        @asset.relate_to_organization
        expect(@asset.organization).to be_nil
      end

      it "should relate asset to a user's organization" do
        org.users << a_user
        @asset.user = a_user
        expect(@asset.organization).to be_nil

        @asset.relate_to_organization
        expect(@asset.organization).to eq(org)
      end
    end
  end

  # CREATING WITH USER

  describe "#create_with_user" do
    let(:new_user){ FactoryGirl.create(:user) }

    let(:asset_params) do
      {
        name: 'some name',
        description: 'some description',
        location: "Some location",
        latitude: "44.122",
        longitude: "45.321",
        material: "MyString",
        date_installed: Date.new(2014, 12, 1),
        condition: Asset::GOOD_CONDITION,
        failure_probablity: Asset::NEITHER_FAILURE,
        failure_consequence: Asset::EXTREMELY_HIGH_CONSEQUENCE,
        status: Asset::OPERATIONAL
      }
    end

    it "should create a new asset" do
      expect {
        Asset.create_with_user(asset_params, new_user).save
      }.to change(Asset, :count).by(1)
    end

    it "should relate the asset to the correct user" do
      asset = Asset.create_with_user(asset_params, new_user)
      expect(asset.user).to eq(new_user)
    end
  end


end
