require 'spec_helper'

describe OrganizationDecorator do
  include_context 'organization_setup'

  before(:each) {
    single_organization_with_users
    @decorated_org = @organization.decorate
  }

  describe 'decoration tests' do
    it 'should be decorated' do
      expect(@decorated_org).to be_decorated
    end

    it 'should be decorated with an OrganizationDecorator' do
      expect(@decorated_org).to be_decorated_with OrganizationDecorator
    end
  end


  describe '#owner_choices' do
    let(:choices_array) do
      choices = [["No change", nil]]
      @organization.users.each do |u|
      choices << ["#{u.email} - #{u.first_name} #{u.last_name}", u.id] unless
        (u.id == @organization.owner.id) || (u.owns)
      end
      choices
    end

    it 'return the correct array' do
      expect(@decorated_org.owner_choices).to eq(choices_array)
    end
  end
end
