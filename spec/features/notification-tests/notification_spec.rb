# frozen_string_literal: true

require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

RSpec.feature "Notifications", type: :feature do
  before(:each) do
    @user1 = FactoryBot.create(:user)
    login_as(@user1, :scope => :user)
    @post = FactoryBot.create(:post)
    @user2 = User.find(@post.user_id)
  end

  scenario "a user sees a notification after getting a comment on their post" do
    # User 1 comments on user 2's post
    visit '/'
    fill_in 'profile_about', with: 'Im a cat!'
    click_button 'Create Profile'

    visit '/posts'
    fill_in "comment[body]", with: "A comment!"
    click_button "Comment"
    logout(@user1)

    # User 2 sees a notification
    login_as(@user2, :scope => :user)
    visit '/'
    fill_in 'profile_about', with: 'Im a cat!'
    click_button 'Create Profile'
    visit "/users/#{@user2.id}/notifications"
    expect(page).to have_content("You have a new comment")
  end

  scenario "users don't see notifications from self comments on self posts" do
    # User 1 comments on user 2's post
    visit '/'
    fill_in 'profile_about', with: 'Im a cat!'
    click_button 'Create Profile'

    visit '/posts'
    fill_in "comment[body]", with: "A comment!"
    click_button "Comment"

    # User 1 sees no notification
    visit "/users/#{@user2.id}/notifications"
    expect(page).not_to have_content("You have a new comment")
  end

  scenario "user can remove one notification" do
    # User 1 comments on user 2's post
    visit '/'
    fill_in 'profile_about', with: 'Im a cat!'
    click_button 'Create Profile'

    visit '/posts'
    fill_in "comment[body]", with: "A comment!"
    click_button "Comment"
    logout(@user1)

    # User 2 removes notification
    login_as(@user2, :scope => :user)
    visit '/'
    fill_in 'profile_about', with: 'Im a cat!'
    click_button 'Create Profile'
    visit "/users/#{@user2.id}/notifications"
    click_button('Remove all notifications')
    expect(page).to_not have_content("You have a new comment")
  end

  scenario "user can remove all notifications" do
    # User 1 comments on user 2's post
    visit '/'
    fill_in 'profile_about', with: 'Im a cat!'
    click_button 'Create Profile'

    visit '/posts'
    fill_in "comment[body]", with: "A comment!"
    click_button "Comment"
    fill_in "comment[body]", with: "A comment!"
    click_button "Comment"
    logout(@user1)

    # User 2 removes notification
    login_as(@user2, :scope => :user)
    visit '/'
    fill_in 'profile_about', with: 'Im a cat!'
    click_button 'Create Profile'
    visit "/users/#{@user2.id}/notifications"
    click_button('Remove all notifications')
    expect(page).to_not have_content("You have a new comment")
  end

  scenario "a user sees a notification after receiving a friend request" do
    # User 1 comments on user 2's post
    visit '/'
    fill_in 'profile_about', with: 'Im a cat!'
    click_button 'Create Profile'
    logout(@user1)

    # User 2 adds user 1
    login_as(@user2, :scope => :user)
    visit '/'
    fill_in 'profile_about', with: 'Im a dog!'
    click_button 'Create Profile'
    visit '/users/profiles'
    click_button 'Add Friend'
    logout(@user2)

    # # User 1 sees a notification
    login_as(@user1, :scope => :user)
    visit "/users/#{@user2.id}/notifications"
    expect(page).to have_content("You have a new friend request")
  end

  scenario "a user sees no notification after accepting a friend request" do
    # User 1 comments on user 2's post
    visit '/'
    fill_in 'profile_about', with: 'Im a cat!'
    click_button 'Create Profile'
    logout(@user1)

    # User 2 adds user 1
    login_as(@user2, :scope => :user)
    visit '/'
    fill_in 'profile_about', with: 'Im a dog!'
    click_button 'Create Profile'
    visit '/users/profiles'
    click_button 'Add Friend'
    logout(@user2)

    # User 1 sees a notification and accepts
    login_as(@user1, :scope => :user)
    visit "/users/#{@user1.id}/notifications"
    click_on('You have a new friend request from name surname.')
    click_button('Accept')

    # User 1 sees no notification
    visit "/users/#{@user1.id}/notifications"
    expect(page).to_not have_content("You have a new friend request")
  end
end