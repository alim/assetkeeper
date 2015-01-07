require 'rails_helper'

RSpec.describe "manufacturers/edit", :type => :view do
  before(:each) do
    @manufacturer = assign(:manufacturer, Manufacturer.create!(
      :name => "MyString",
      :address => "MyString",
      :website => "MyString",
      :main_phone => "MyString",
      :main_fax => "MyString",
      :tags => "MyString"
    ))
  end

  it "renders the edit manufacturer form" do
    render

    assert_select "form[action=?][method=?]", manufacturer_path(@manufacturer), "post" do

      assert_select "input#manufacturer_name[name=?]", "manufacturer[name]"

      assert_select "input#manufacturer_address[name=?]", "manufacturer[address]"

      assert_select "input#manufacturer_website[name=?]", "manufacturer[website]"

      assert_select "input#manufacturer_main_phone[name=?]", "manufacturer[main_phone]"

      assert_select "input#manufacturer_main_fax[name=?]", "manufacturer[main_fax]"

      assert_select "input#manufacturer_tags[name=?]", "manufacturer[tags]"
    end
  end
end
