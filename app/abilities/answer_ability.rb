# frozen_string_literal: true

##
# This is the Ability class for the Answer model
#
# It is responsible for handling the permissions of the
# different User instance <tt>roles</tt> for any Answer
#
# In this case, they are, as follow:
# * <b>Everybody</b> can acess <tt>index</tt> and <tt>show</tt> an Answer in the FAQ
# * <b>Everybody</b> can make a <tt>query</tt> to the FAQ
# * User with role <tt>admin</tt> can <tt>create</tt>, <tt>update</tt> and
#   <tt>destroy</tt> an Answer
# * User which return true to the method #faq_creator? can <tt>create</tt> an Answer
# * User that created the Answer, can <tt>update</tt> and <tt>destroy</tt> it
class AnswerAbility
  include CanCan::Ability
  include ApplicationHelper

  # Initialization telling which User instance can do what, following the rules
  # defined above
  def initialize(user)
    can :read, Answer.on_faq # Everybody can read the FAQs...
    can :query_faq, Answer # ...and query it

    can :manage, Answer if user.admin?
    can :create, Answer if faq_creator?(user)
    can %i[read update destroy], Answer.from_user(user.id) if faq_creator?(user)
  end

  # Helper called by #new, that returns a boolean indicating if the
  # User instance passed as parameter can add an Answer to the FAQ
  def faq_creator?(user)
    user.faq_inserter? || support_user?(user)
  end
end
