# Provide shared macros for testing user accounts
shared_context 'asset_setup' do

	let(:assets) do
	  5.times.each { FactoryGirl.create(:asset_item) }
      @asset = AssetItem.last
	end

  let(:assets_with_users) do
    @user = FactoryGirl.create(:user)
    @user.save

    5.times.each { FactoryGirl.create(:asset_item, user: @user) }
    @asset = AssetItem.last
  end

  let(:assets_with_users_and_org) do
    @user_with_org = FactoryGirl.create(:user)
    @user_with_org.save

    @org = FactoryGirl.create(:organization, owner: @user_with_org)
    @org.save

    @user_with_org.organization = @org
    @user_with_org.save

    5.times.each { FactoryGirl.create(:asset_item, user: @user_with_org, organization: @org) }
    @asset_with_org = AssetItem.last
  end

end
