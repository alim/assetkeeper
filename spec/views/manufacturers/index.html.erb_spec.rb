require 'rails_helper'

RSpec.describe "manufacturers/index", :type => :view do
  before(:each) do
    assign(:manufacturers, [
      Manufacturer.create!(
        :name => "Name",
        :address => "Address",
        :website => "Website",
        :main_phone => "Main Phone",
        :main_fax => "Main Fax",
        :tags => "Tags"
      ),
      Manufacturer.create!(
        :name => "Name",
        :address => "Address",
        :website => "Website",
        :main_phone => "Main Phone",
        :main_fax => "Main Fax",
        :tags => "Tags"
      )
    ])
  end

  it "renders a list of manufacturers" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Address".to_s, :count => 2
    assert_select "tr>td", :text => "Website".to_s, :count => 2
    assert_select "tr>td", :text => "Main Phone".to_s, :count => 2
    assert_select "tr>td", :text => "Main Fax".to_s, :count => 2
    assert_select "tr>td", :text => "Tags".to_s, :count => 2
  end
end
