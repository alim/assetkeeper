# Provide shared macros for testing user accounts
shared_context 'asset_setup' do

	let(:assets) {
	  5.times.each { FactoryGirl.create(:asset) }
    @asset = Asset.last
	}

  let(:assets_with_users) {
    @user = FactoryGirl.create(:user)
    @user.save
    5.times.each { FactoryGirl.create(:asset, user: @user) }
    @asset = Asset.last
  }

end
