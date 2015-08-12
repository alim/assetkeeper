# Provide shared macros for testing user accounts
shared_context 'user_setup' do
  let(:create_users) do
    5.times.each { FactoryGirl.create(:user) }
  end

  let(:create_service_admins) do
    5.times.each { FactoryGirl.create(:adminuser) }
  end

  let(:create_users_with_account) do
    5.times.each { FactoryGirl.create(:user_with_account) }
  end

  let(:delete_users) { User.destroy_all }

  let(:signin_admin) do
    @signed_in_user = FactoryGirl.create(:adminuser)
    sign_in @signed_in_user
  end

  let(:signin_customer) do
    @signed_in_user = FactoryGirl.create(:user)
    sign_in @signed_in_user
  end

  # Logout of current user and login as an administrator
  let(:login_admin) do
    sign_out subject.current_user
    signin_admin
    expect(subject.current_user).not_to be_nil
  end
end
