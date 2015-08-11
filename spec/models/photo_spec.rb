require 'spec_helper'

RSpec.describe Photo, type: :model do
  include_context 'photo_setup'

  before(:each) { photos_with_user }

  after(:each) do
    User.destroy_all
    Photo.destroy_all
    Organization.destroy_all
  end

  ## VALIDATION CHECKS -------------------------------------------------
  describe 'Validation checks' do
    describe 'valid tests', :vcr do
      it 'valid with a user and NO organization' do
        expect(@photo).to be_valid
      end

      it 'have an attachment' do
        expect(@photo).to have_mongoid_attached_file(:image)
      end
    end

    pending 'Invalid tests', :vcr do
      it 'Should be invalid without a name' do
        @photo.name = nil
        expect(@photo).not_to be_valid
      end

      it 'Should be invalid without a description' do
        @photo.description = nil
        expect(@photo).not_to be_valid
      end

      it 'Should be invalid without a user_id' do
        photo = FactoryGirl.build(:photo_item)
        expect(photo).not_to be_valid
      end

      it 'photo should be destroyed, if user is destroyed' do
        user = @photo.user
        user.destroy
        expect {
          @photo.reload
        }.to raise_error(Mongoid::Errors::DocumentNotFound)
      end
    end
  end

  ## ORGANIZATIONAL CONCERN -------------------------------------------

  describe 'Organizational concern tests', :vcr do
    describe 'scope tests' do
      let(:new_user) { FactoryGirl.create(:user) }
      let(:other_photo) { FactoryGirl.create(:photo, user: new_user) }

      before(:each) do
        other_photo
      end

      it 'should find photos with matching user, but no organization' do
        photos = Photo.in_organization(@photo.user)
        photos.each do |photo|
          expect(photo.user_id).to eq(@photo.user.id)
          expect(photo.organization).to be_nil
        end

        expect(photos.count).to be <  Photo.count
      end

      it 'should find a subset of the photos' do
        photos = Photo.in_organization(@photo.user)
        expect(photos.count).to be > 0
        expect(photos.count).to be <  Photo.count
      end

      it 'should find all photos part of the user organization' do
        # Create photos with different owners and
        5.times { other_photo }
        owner = User.last
        org = FactoryGirl.create(:organization, owner: owner)

        # Find photos not matching owner
        photos = Photo.ne(user_id: owner.id)
        expect(photos.count).to be > 0

        # Add photos to organization
        org.photos << photos

        # user_photos = photo.where(user_id: @photo.user_id)
        found_photos = Photo.in_organization(photos.last.user)

        expect(found_photos.count).to be > 0

        found_photos.each do |photo|
          expect(photo.organization.id).to eq(org.id)
          expect(photo.organization.id).not_to be_nil
          expect(photo.user).not_to eq owner
        end
      end
    end

    describe 'relate_to_organization tests' do
      let(:org_owner) { FactoryGirl.create(:user) }
      let(:org) { FactoryGirl.create(:organization, owner: org_owner) }
      let(:a_user) { FactoryGirl.create(:user) }

      it 'do not relate photo to an organization if user is not part of it' do
        expect(@photo.organization).to be_nil
        @photo.relate_to_organization
        expect(@photo.organization).to be_nil
      end

      it 'should relate photo to a user organization' do
        org.users << a_user
        @photo.user = a_user
        expect(@photo.organization).to be_nil

        @photo.relate_to_organization
        expect(@photo.organization).to eq(org)
      end
    end
  end

  ## CREATING WITH USER -----------------------------------------------

  describe '#create_with_user', :vcr do
    let(:new_user) { FactoryGirl.create(:user) }

    let(:photo_params) do
      {
        name: 'some name',
        description: 'some description',
        lat: '44.122',
        long: '45.321'
      }
    end

    it 'should create a new photo' do
      expect {
        Photo.create_with_user(photo_params, new_user).save
      }.to change(Photo, :count).by(1)
    end

    it 'should relate the photo to the correct user' do
      photo = Photo.create_with_user(photo_params, new_user)
      expect(photo.user).to eq(new_user)
    end
  end
end
