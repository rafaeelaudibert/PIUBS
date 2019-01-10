# frozen_string_literal: true

##
# This is the Ability class for the Reply model
#
# It is responsible for handling the permissions of the
# different User instance <tt>roles</tt> for any Reply
#
# In this case, they are, as follow:
# * <b>Everybody</tt> EXCEPT User instances with a <tt>faq_insert</tt> role
#   can create a Reply
#   <tt>new, destroy</tt> and <tt>download</tt> views for any Contract
# * User instances with the role <tt>admin</tt> can <tt>read</tt> any Reply
# * User instances with a <tt>admin</tt> or a <tt>support-like</tt> role can
#   verify the Attachment instances related to a Reply
class ReplyAbility
  include CanCan::Ability
  include ApplicationHelper

  # Initialization telling which User instance can do what, following the rules
  # defined above
  def initialize(user)
    can :create, Reply unless user.faq_inserter?
    can :read, Reply if user.admin?
    can :verify_attachments, Reply if user.admin? || support_user?(user)
  end
end
