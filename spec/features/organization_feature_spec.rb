require 'spec_helper'

describe "Sign up for new account", :type => :feature do
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

    end
  end

  context 'Non-owner member access' do
    let(:non_owner) { User.where(:id.in => @organization.users.pluck(:id)).where(:id.ne => @organization.owner.id).first }

    let(:sign_in_non_owner) do
      visit new_user_session_url
      fill_in 'user_email', with: non_owner.email
      fill_in 'user_password', with: 'somepassword'
      click_button 'Login'
    end

    before do
      single_organization_with_users
      sign_in_non_owner
    end

    describe 'edit as non_owner' do
      let(:edit_org) { visit edit_organization_url(@organization) }

      it 'should not allow editing' do
        edit_org
        expect(page).to have_content('You are not authorized to access the requested Organization.')
      end
    end

    describe 'show as non_owner' do
      let(:show_org) { visit organization_url(@organization) }

      it 'should the correct organization' do
        show_org
        expect(page).to have_content(@organization.name)
        expect(page).to have_content(@organization.owner.email)
      end

      it 'should the correct organization owner' do
        show_org
        expect(page).to have_content(@organization.owner.first_name)
        expect(page).to have_content(@organization.owner.last_name)
        expect(page).to have_content(@organization.owner.email)
      end

      it 'should show the correct members' do
        show_org
        @organization.users do |user|
          expect(page).to have_content(user.first_name)
          expect(page).to have_content(user.last_name)
          expect(page).to have_content(user.email)
        end
      end
    end
  end
end
