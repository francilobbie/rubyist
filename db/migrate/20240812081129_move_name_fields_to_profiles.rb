class MoveNameFieldsToProfiles < ActiveRecord::Migration[7.1]
  def up
    User.find_each do |user|
      Profile.create!(
        user: user,
        first_name: user.first_name,
        last_name: user.last_name,
        bio: '',  # You may choose to provide a default value for other fields
        location: '',
      )
    end

    remove_column :users, :first_name, :string
    remove_column :users, :last_name, :string
  end

  def down
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string

    Profile.find_each do |profile|
      user = profile.user
      user.update!(
        first_name: profile.first_name,
        last_name: profile.last_name
      )
    end
  end
end
