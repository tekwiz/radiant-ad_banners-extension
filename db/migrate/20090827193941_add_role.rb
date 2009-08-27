class AddRole < ActiveRecord::Migration
  def self.up
    Role.create(:role_name => 'Ads', :description => 'Only users in the Ads role may modify the ads.')
  end

  def self.down
  end
end
