# Provide shared macros for testing user accounts
shared_context 'organization_setup' do

  # Single organization with multiple users
	let(:single_organization_with_users) {
		4.times.each { FactoryGirl.create(:user_with_account) }
		@owner = FactoryGirl.create(:user_with_account)
		@organization = FactoryGirl.create(:organization, owner: @owner)
		User.all.each {|user| @organization.users << user}
	}

	let(:multiple_organizations){
		5.times.each { FactoryGirl.create(:organization,
			owner: FactoryGirl.create(:user)
		)}
	}
end
