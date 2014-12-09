require "spec_helper"

describe OrganizationMailer, :type => :mailer do
  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true

    # Collect al deliveries into an array
    ActionMailer::Base.deliveries = []

    @organization = FactoryGirl.build(:organization)
    @user = FactoryGirl.create(:user)
    @organization.owner_id = @user.id
    @organization.save

    @organization_email = OrganizationMailer.member_email(@user, @organization).deliver
  end


  after(:each) do
    ActionMailer::Base.deliveries.clear
    User.destroy_all
  end

  it 'should send an email' do
    expect(ActionMailer::Base.deliveries.count).to eq(1)
  end

  it 'renders the receiver email' do
    expect(ActionMailer::Base.deliveries.first.to).to eq([@user.email])
  end

  it 'renders the sender email' do
    expect(ActionMailer::Base.deliveries.first.from).to eq([OrganizationMailer::ORGANIZATION_FROM_EMAIL])
  end

end
