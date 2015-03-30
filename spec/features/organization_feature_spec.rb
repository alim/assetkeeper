require 'spec_helper'

describe "Sign up for new account", :type => :feature do
  include_context 'organization_setup'

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

  describe 'Edit actions' do
    let(:edit_org) { visit edit_organization_url(@organization) }

    it 'Edit template should be visible' do
      edit_org
      expect(page).to have_content('Edit Organization')
    end

    describe 'Change Organization Owner' do
      it 'Edit template should change owner section' do
        edit_org
        expect(page).to have_content('Change Organization Owner')
      end

      it 'Should have a drop down list showing other users' do
        select_options = []
        choices = @organization.decorate.owner_choices

        choices.each {|c| select_options << c[0]}
        edit_org
        expect(page).to have_select('organization_owner_id', select_options)
      end
    end

    context 'Non-owner access' do
    end
  end
end
