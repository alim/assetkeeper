require 'spec_helper'

describe "Cancel account", :type => :feature do
  include_context 'organization_setup'

  context 'Owner access' do
    let(:sign_in_owner) do
      visit new_user_session_url
      fill_in 'user_email', with: @owner.email
      fill_in 'user_password', with: 'somepassword'
      click_button 'Login'
    end

    before do
      single_organization_with_users
      sign_in_owner
    end

    after do
      Organization.destroy_all
      User.destroy_all
    end

    describe 'Cancel account actions' do
      let(:edit_account) { visit edit_user_registration_url }

      it 'Edit profile should be visible' do
        edit_account
        expect(page).to have_content('Edit Profile')
      end

      it 'Cancel should redirect to edit_user_registration_url' do
        edit_account
        click_link 'Cancel Account'
        expect(page.current_path).to eq(edit_user_registration_path)
      end

      it 'Cancel should display a flash message' do
        edit_account
        click_link 'Cancel Account'
        expect(page).to have_content('Error deleting your account')
      end
    end
  end

end
