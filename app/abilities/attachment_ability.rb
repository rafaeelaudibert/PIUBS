# frozen_string_literal: true

##
# This is the Ability class for the Attachment model
#
# It is responsible for handling the permissions of the
# different User instance <tt>roles</tt> for any Attachment
#
# In this case, they are, as follow:
# * <b>Everybody</b> can <tt>create</tt> an Attachment
# * User with role <tt>admin</tt> can <tt>create</tt>, <tt>update</tt>,
#   <tt>destroy</tt> and <tt>download</tt> any Attachment
# * User with a <tt>support-like</tt> role  can <tt>download</tt> any Attachment
# * Other User instances can only download an attachment in specific cases
#   descibred on #check_download_restrictions and its auxiliar functions
class AttachmentAbility
  include CanCan::Ability
  include ApplicationHelper

  # "Fake" Initialization just checking the <tt>user</tt> parameter existence
  def initialize(user, attachment)
    initializer(user, attachment) if user
  end

  # Initialization telling which User instance can do what, following the rules
  # defined above
  def initializer(user, attachment)
    can :create, Attachment # Every logged user can create an attachment
    can %i[manage download], Attachment if user.admin?
    can :download, Attachment if support_user?(user)

    can :download, Attachment if attachment && downloadable?(user, attachment)
  end

  private

  # Verifies if the Attachment instance passed as a paramater
  # can be downloaded by the User instance also passed as a parameter
  # following the rules defined above, asking if it can access
  # any of the resources linked to the Attachment
  def downloadable?(user, attachment)
    attachment.attachment_links.any? do |link|
      check_download_restrictions user, link
    end
  end

  # Check if the User has acess to the LinkAttachment passed as a parameter
  # from every possible source: Answer, Reply, Call, Controversy or Feedback
  def check_download_restrictions(user, link)
    can_download_from_answer(user, link) ||
      can_download_from_reply(user, link) ||
      can_download_from_call(user, link) ||
      can_download_from_controversy(user, link) ||
      can_download_from_feedback(user, link)
  end

  # Returns a boolean indicating if the User instance passed as a parameter
  # has or not access to this LinkAttachment which might be related to an Answer
  def can_download_from_answer(user, link)
    call = link.answer.try(:call) if link.answer?

    (!call.nil? && can_see_call?(user, call)) || link.try(:answer).try(:faq?)
  end

  # Returns a boolean indicating if the User instance passed as a parameter
  # has or not access to this LinkAttachment which might be related to a Call
  def can_download_from_call(user, link)
    call = link.call if link.call?

    !call.nil? && can_see_call?(user, call)
  end

  # Returns a boolean indicating if the User instance passed as a parameter
  # has or not access to this LinkAttachment which might be related to a Reply
  def can_download_from_reply(user, link)
    repliable = link.reply.repliable if link.reply?

    !repliable.nil? && if repliable.class.method_defined? :user_id
                         can_see_call?(user, repliable)
                       else
                         controversy_user_allowed(user, repliable)
                       end
  end

  # Returns a boolean indicating if the User instance passed as a parameter
  # has or not access to this LinkAttachment which might be related to a Controversy
  def can_download_from_controversy(user, link)
    controversy = link.controversy if link.controversy?

    !controversy.nil? && controversy_user_allowed(user, controversy)
  end

  # Returns a boolean indicating if the User instance passed as a parameter
  # has or not access to this LinkAttachment which might be related to a Feedback
  def can_download_from_feedback(user, link)
    controversy = link.feedback.controversy if link.feedback?

    !controversy.nil? && controversy_user_allowed(user, controversy)
  end

  # Called by #can_download_from_call or #can_download_from_reply, returns true
  # if the </tt>current_user</tt> has a <tt>company</tt> role which allows him
  # to see the Call instance passed as a parameter
  def can_see_call?(user, call)
    (user.company_admin? && call.sei == user.sei) || (user.company_user? && call.user_id == user.id)
  end

  # Called by #can_download_from_reply, #can_download_from_controversy or
  # #can_download_from_feedback, returns true if the </tt>current_user</tt>
  # is allowed to see the Controversy instance passed as a parameter
  def controversy_user_allowed(user, controversy)
    controversy.company_user == user ||
      controversy.city_user == user ||
      controversy.unity_user == user ||
      (user.company_admin? && controversy.sei == user.sei)
  end
end
