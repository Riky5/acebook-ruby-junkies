class FriendRequest < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: 'User'

  validate :not_self
  validate :not_friends
  validate :not_pending

  has_many :notifications, as: :recipient, dependent: :destroy
  has_noticed_notifications param_name: :parent, destroy: true, model_name: "Notification"

  def accept
    user.friends << friend
    destroy
  end

  private

  def not_self
    errors.add(:friend, "can't be equal to user") if user == friend
  end

  def not_friends
    errors.add(:friend, 'is already added') if user.friends.include?(friend)
  end

  def not_pending
    errors.add(:friend, 'already requested friendship') if friend.pending_friends.include?(user)
  end

  after_create_commit :notify_recipient
  
  private
  
  def notify_recipient
    recipient = User.find(friend.id)
    sender = User.find(user_id)
    requester = "#{sender.name} #{sender.surname}"
    FriendRequestNotification.with(parent: self, message: self, sender: sender, requester: requester).deliver_later(recipient) unless recipient == sender
  end
end
