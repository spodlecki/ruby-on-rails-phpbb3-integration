# == Schema Information
#
# Table name: users
#
#  id                  :integer(4)      default(0), not null, primary key
#  created_at          :datetime
#  updated_at          :datetime
#  post_count          :integer(8)      default(0), not null
#  rank                :integer(8)      default(0), not null
#  username            :string(255)     not null
#  email               :string(255)     not null
#  options             :string(255)

class User < ActiveRecord::Base
  # Change this to your phpBB's cookie name, found in the administration panel.
  PHPBB_COOKIE_NAME = 'phpbb_CHANGE_ME'
  
  # Most likely, this will work just fine. But you are able to change the prefix of your forum's table. If you did, change it here... and you'll need to change it below as well
  PHPBB_TABLE_NAME = 'phpbb'

  # By default, the cookie session length is 3600. You may either: a) set this to a different INT or b) set to nil and it will download from the database.
  PHPBB_SESSION_LENGTH = 3600 # seconds

  ANONYMOUS_UID = 1

  attr_accessible :options

  # Associations
    # Build associations here
  # Filters
    # Any before_* after_* ?

  # Validations
  validates_uniqueness_of :username,:email

  def update_phpbb_data
    @phpbb_data = PhpBbUsersTable.find(id)
  end


  # First call the application_controller will make to the User ActiveRecord. This will get or create a new user.
  def self.create_or_return_user_object(external)
    user = User.find_by_id(external[:user_id])
    if user.nil?
      user = User.new
      user.id = external[:user_id]
      user.post_count = external[:user_posts]
      user.username = external[:username]
      user.email = external[:user_email]
      user.rank = external[:user_rank]
      user.save
    else
      user.update_phpbb_data
    end
    user
  end

  # Get the user's session from phpbb_session, make sure it isn't expired though.
  # Added session_time due to the actual cookie being set to X Days in config, but session timeout is different.
  # If you have auto-login setup and what not, go ahead and alter the code as needed.
  def self.get_user_from_cookies(cookies)
    session = PhpBbUsersTable.find(
                :first,
                :joins => [:session],
                :select => "#{PHPBB_TABLE_NAME}_users.*",
                :conditions => ["#{PHPBB_TABLE_NAME}_sessions.session_id = ? AND #{PHPBB_TABLE_NAME}_sessions.session_user_id = ? AND #{PHPBB_TABLE_NAME}_sessions.session_time >= ?", current_user_cookie_session(cookies), current_user_cookie_guid(cookies), (Time.now - (PhpBbConfigTable.session_length).seconds).to_i ]
              )
    unless session.nil? || current_user_cookie_guid(cookies) == ANONYMOUS_UID
      create_or_return_user_object(session)
    else
      nil
    end
  end

  # Method that will keep the phpbb3's session alive.
  def self.update_user_session(cookies,request)
    session = PhpBbSessionsTable.find_by_session_id(
                current_user_cookie_session(cookies), 
                :conditions => ["#{PHPBB_TABLE_NAME}_sessions.session_user_id = ? AND #{PHPBB_TABLE_NAME}_sessions.session_time >= ?", current_user_cookie_guid(cookies), (Time.now - (PhpBbConfigTable.session_length).seconds).to_i ]
              )
    unless session.nil? || current_user_cookie_guid(cookies) == ANONYMOUS_UID
      session.update_attributes({ :session_time => Time.now.to_i, :session_page => request.fullpath})
    end
  end
  
  # Returns the cookie's session id
  def self.current_user_cookie_session(cookies)
    cookies["#{PHPBB_COOKIE_NAME}_sid"]
  end
  
  # Returns the cookies user id (phpbb3 user)
  def self.current_user_cookie_guid(cookies)
    cookies["#{PHPBB_COOKIE_NAME}_u"]
  end

  class PhpBbUsersTable < ActiveRecord::Base
    if Rails.env.production?
      establish_connection :phpbb_database_production
    else
      establish_connection :phpbb_database_development
    end

    # Change to your table name if different
    set_table_name :phpbb_users
    set_primary_key :user_id

    has_one :session, :class_name => 'PhpBbSessionsTable', :foreign_key => 'session_user_id'
  end

  class PhpBbConfigTable < ActiveRecord::Base
    if Rails.env.production?
      establish_connection :phpbb_database_production
    else
      establish_connection :phpbb_database_development
    end

    # Change to your table name if different
    set_table_name :phpbb_config
    set_primary_key :config_name

    def self.session_length
      PHPBB_SESSION_LENGTH || self.find(:first, :select => "#{PHPBB_TABLE_NAME}_config.config_value",:conditions => {:config_name => 'session_length'}).config_value.to_i
    end
  end

  class PhpBbSessionsTable < ActiveRecord::Base
    if Rails.env.production?
      establish_connection :phpbb_database_production
    else
      establish_connection :phpbb_database_development
    end
    
    # Change to your table name if different
    set_table_name :phpbb_sessions

    set_primary_key :session_id
    belongs_to :user, :class_name => 'PhpBbUsersTable', :foreign_key => 'session_user_id'
  end

end
