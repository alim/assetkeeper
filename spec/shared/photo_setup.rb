# Provide shared macros for testing user accounts
shared_context 'photo_setup' do

	let(:photos) do
	  5.times.each { FactoryGirl.create(:photo) }
      @photo = Photo.last
	end

  let(:photos_with_user) do
    @user = FactoryGirl.create(:user)
    @user.save

    @photo = FactoryGirl.create(:photo, user: @user)
  end

  let(:photos_with_users_and_org) do
    @user_with_org = FactoryGirl.create(:user)
    @user_with_org.save

    # Create organization and add users to it.
    @org = FactoryGirl.create(:organization, owner: @user_with_org)
    5.times.each { @org.users << FactoryGirl.create(:user) }
    @org.save

    @user_with_org.organization = @org
    @user_with_org.save

   @photo_with_org =  FactoryGirl.create(:photo, user: @user_with_org, organization: @org)
  end
end
