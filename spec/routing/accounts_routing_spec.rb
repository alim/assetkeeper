require "spec_helper"

describe UsersController, :type => :routing do
  describe "routing" do

    it "route to #index should not exist" do
      expect(get: "/users/1/accounts").not_to be_routable
    end

    it "route to #show should not exist" do
      expect(get: "/users/1/accounts/2").not_to be_routable
    end

    it "routes to #new" do
      expect(get("/users/1/accounts/new")).to route_to("accounts#new",
        user_id: '1')
    end

    it "routes to #edit" do
      expect(get("/users/1/accounts/2/edit")).to route_to("accounts#edit",
        user_id: "1", id: '2')
    end

    it "routes to #create" do
      expect(post("/users/1/accounts")).to route_to("accounts#create",
        user_id: '1')
    end

    it "routes to #update" do
      expect(put("/users/1/accounts/2")).to route_to("accounts#update",
        user_id: "1", id: '2')
    end

    it "routes to #destroy" do
      expect(delete("/users/1/accounts/2")).to route_to("accounts#destroy",
        user_id: "1", id: '2')
    end

  end
end
