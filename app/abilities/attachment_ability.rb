# frozen_string_literal: true

class AttachmentAbility
  include CanCan::Ability
  include ApplicationHelper

  def initialize(user, attachment)
    if user
      can :create, Attachment # Every logged user can create an attachment
      can %i[manage download], Attachment if user.admin?
      can :download, Attachment if support_user?(user)

      can :download, Attachment if attachment && downloadable?(user, attachment)
    end
  end

  protected

  def downloadable?(user, attachment)
    attachment.attachment_links.all? do |link|
      check_download_restrictions user, link
    end
  end

  def check_download_restrictions(user, link)
    can_download_answer(user, link) &&
      can_download_reply(user, link) &&
      can_download_call(user, link) &&
      can_download_controversy(user, link) &&
      can_download_feedback(user, link)
  end

  def can_download_answer(user, link)
    call = Call.where(answer_id: link.answer_id).first if link.call?

    call.nil? || link.answer.faq? || company_user_allowed(user, call)
  end

  def can_download_reply(user, link)
    call = link.reply.repliable if link.reply?

    call.nil? || company_user_allowed(user, call)
  end

  def can_download_call(user, link)
    call = link.call if link.call?

    call.nil? || company_user_allowed(user, call)
  end

  def can_download_controversy(user, link)
    controversy = link.controversy if link.controversy?

    controversy.nil? || controversy_user_allowed(user, controversy)
  end

  def can_download_feedback(user, link)
    controversy = link.feedback.controversy if link.feedback?

    controversy.nil? || controversy_user_allowed(user, controversy)
  end

  def company_user_allowed(user, call)
    (user.company_admin? && call.sei == user.sei) || (user.company_user? && call.user_id == user.id)
  end

  def controversy_user_allowed(user, controversy)
    controversy.company_user == user ||
      controversy.city_user == user ||
      controversy.unity_user == user ||
      (user.company_admin? && controversy.sei == user.sei)
  end
end
