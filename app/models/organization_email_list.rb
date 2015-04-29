class UserEmailList
  PASSWORD_LENGTH = 12

  attr_reader :email_list

  def initialize(email_list)
    @email_list = email_list
  end

  def members_list(org)
    return false unless email_list

    errors = []
    email_list.split.each do |email|
      unless email.match(/^.+@.+\..+/)
        errors.add(:members, "invalid email address - #{email}")
      end
    end
  end

  ######################################################################
  # The lookup_user method will take an string of white-space separated
  # email addresses and return a hash based on the email addresses
  # as keys. The value of the hash will be a User or nil, depending on
  # whether the email address indicates a current user. The method will
  # return HASH, if it can successfully process all user email addresses
  # or nil if it cannot. The method will check for valid email
  # address format, while processing. The method also takes the Group
  # record as the parameter. It assumes that group.members holds the
  # email list.
  ######################################################################
  def lookup_users
    users = {}     # Hash for returning results
    return users unless @email_list

    @email_list.split.each do |email|
      if (user = User.where(email: email).first).present?
        users[email] = user
      else
        users[email] = nil
      end
    end
    users
  end

  ######################################################################
  # The create_notify method will look to see if members have been assigned
  # to the Group. For each email address that has nil user record, this
  # method will create a new User record for the requested member. The
  # new user will be notified of their new account. Each newly created
  # user will be associated with the current group.
  ######################################################################
  def create_notify(org)
    binding.pry
    lookup_users.each do |member, user|
      if user.nil?
        new_password = Devise.friendly_token.first(PASSWORD_LENGTH)
        user = User.create!(first_name: '*None*', last_name: '*None*',
                            role: User::CUSTOMER, email: member.dup,
                            password: new_password,
                            password_confirmation: new_password,
                            phone: '888.555.1212')
      end
      org.users << user
      OrganizationMailer.member_email(user, self).deliver
    end
  end
end
