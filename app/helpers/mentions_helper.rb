# app/helpers/mentions_helper.rb
module MentionsHelper
  def parse_mentions(text)
    text.gsub(/@\[(.*?)\]\((\d+)\)/) do |mention|
      username = $1
      user_id = $2
      user = User.find_by(id: user_id)

      if user
        link_to("@#{user.username}", user_profile_path(user), class: 'mention-link')
      else
        "@#{username}"
      end
    end.html_safe
  end
end
