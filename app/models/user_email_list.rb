###########################################################################
# The UserEmailList class is a server class that is used for managing
# the email list that is associated with an Organization class during
# the create or editing of an Organization record. The email list is
# not stored with the Organization class is only a temporary service
# object used to create, notify and invite organization members.
###########################################################################
class UserEmailList
  PASSWORD_LENGTH = 12

  attr_reader :email_list

  #########################################################################
  # Initializes the class with a whitespace separated list of email
  # addresses.
  #########################################################################
  def initialize(email_list)
    @email_list = email_list
  end

  #########################################################################
  # Checks to insure that all email addresses in the list are correctly
  # formatted.
  #########################################################################
  def check_list
    return false unless email_list

    errors = []
    email_list.split.each do |email|
      unless email.match(/^.+@.+\..+/)
        errors << "invalid email address - #{email}"
      end
    end
    errors
  end

  #########################################################################
  # The create_notify method will look to see if members have been assigned
  # to the Group. For each email address that has nil user record, this
  # method will create a new User record for the requested member. The
  # new user will be notified of their new account. Each newly created
  # user will be associated with the current group.
  #########################################################################
  def create_users
    users = []
    lookup_users.each do |member, user|
      if user.nil?
        new_password = Devise.friendly_token.first(PASSWORD_LENGTH)
        user = User.create!(first_name: '*None*', last_name: '*None*',
                            role: User::CUSTOMER, email: member.dup,
                            password: new_password,
                            password_confirmation: new_password,
                            phone: '888.555.1212')
      end
      users << user
    end
    users.present? ? users : nil
  end

  private

  #########################################################################
  # The lookup_user method will take an string of white-space separated
  # email addresses and return a hash based on the email addresses
  # as keys. The value of the hash will be a User or nil, depending on
  # whether the email address indicates a current user. The method will
  # return HASH, if it can successfully process all user email addresses
  # or nil if it cannot. The method will check for valid email
  # address format, while processing. The method also takes the Group
  # record as the parameter. It assumes that group.members holds the
  # email list.
  #########################################################################
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
end
