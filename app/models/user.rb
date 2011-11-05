class User < ActiveRecord::Base
  attr_accessor   :password
  attr_accessible :name, :email, :password, :password_confirmation
  
  has_many :microposts, :dependent => :destroy
  
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates :name,  :presence => true, 
                    :length   => { :maximum => 50 }
  validates :email, :presence   => true, 
                    :format     => {:with => email_regex},
                    :uniqueness => {:case_sensitive => false}
  validates :password, :presence => true,
                       :confirmation => true,
                       :length   => {:within => 6..40 }
                       
  before_save :encrypt_password       #before saving anything, it will run the encrypt_password method - this will ensure that the encrypted password is set in the db 
  
  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)  #guessing the submitted expects params
  end
  
  def feed
    Micropost.where("user_id =?", id)
  end
  
  class << self
    def authenticate(email, submitted_password)
      user = find_by_email(email)
      (user && user.has_password?(submitted_password)) ? user : nil
    end
    
    def authenticate_with_salt(id, cookie_salt)
      user = find_by_id(id)
      (user && user.salt == cookie_salt) ? user : nil #ternary operator
    end
  end
    
  private       #states that the methods below are only accessible within the model
    def encrypt_password  
      self.salt = make_salt if self.new_record?  #new_record? is a boolean method from activerecord
      self.encrypted_password = encrypt(self.password)
    end
    
    def encrypt(string)
      secure_hash("#{salt}--#{string}") 
    end
    
    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end
    
    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end
    
end





# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#  admin              :boolean         default(FALSE)
#

