require 'spec_helper'

describe ApplicationHelper, :type => :helper do
  describe "#active method tests" do
    it "should return active string, if the path matches" do
      helper.request.path = admin_path
      expect(helper.active(admin_path)).to eq("class=active")
    end

    it "if organization path and settings selected, should return active" do
      helper.request.path = organizations_path
      expect(helper.active('/settings')).to eq("class=active")
    end

    it "if project path and settings selected, should return active" do
      helper.request.path = projects_path
      expect(helper.active('/settings')).to eq("class=active")
    end

    it "if edit user path and settings selected, should return active" do
      helper.request.path = edit_user_registration_path
      expect(helper.active('/settings')).to eq("class=active")
    end

    it "should return empty string, if the path does not match" do
      helper.request.path = 'some_path'
      expect(helper.active(admin_path)).to be_nil
    end
  end
end
