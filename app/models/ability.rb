class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :create, :read, :update, :destroy, :to => :crud

  	# Check to see if we can get the role attribute
  	if !user.nil?

      # The service administrator should have access to all resources
			if user.role == User::SERVICE_ADMIN
				can :manage, :all
			end

			# Only allow customer to manager their own records or records
			# that belong to part of their group.
			if user.role == User::CUSTOMER

        can :crud, AssetItem do |asset|
          asset.organization_id == user.organization_id ||
          asset.user_id == user.id
        end

        can :crud, Account, user: {id: user.id}
        can :crud, Subscription, user_id: user.id
        can :read, Manufacturer

        can [:create, :read, :update, :notify, :destroy], Organization, owner_id: user.id
        can [:read], Organization do |org|
          user.organization == org
        end

        can [:show, :update, :destroy], User, id: user.id

				can :crud, Project do |project|
					project.organization_id == user.organization_id ||
          project.user_id == user.id
				end

			end
		end
  end
end
