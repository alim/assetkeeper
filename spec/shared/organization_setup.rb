# Provide shared macros for testing user accounts
shared_context 'organization_setup' do

  # Single organization with multiple users
	let(:single_organization_with_users) {
		4.times.each { FactoryGirl.create(:user_with_account) }
		@owner = FactoryGirl.create(:user_with_account)
		@organization = FactoryGirl.create(:organization, owner: @owner)
		@organization.members = ''

		User.all.each do |user|
			@organization.users << user
			@organization.members = @organization.members + '  ' + user.email
		end
	}

	let(:multiple_organizations){
		5.times.each { FactoryGirl.create(:organization,
			owner: FactoryGirl.create(:user)
		)}
	}
end
