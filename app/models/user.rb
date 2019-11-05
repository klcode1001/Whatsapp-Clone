class User < ApplicationRecord

    attr_reader :password

    validates :first_name, :last_name, :phone_number, :passwor_digest, :session_token, presence: true
    validates :phone_number, uniqueness: true
    validates :password, length: { minimum: 6 }, allow_nil: true

    after_initialize :ensure_session_token

    def self.find_by_credentials(phone_number, password)
        user = User.find_by(phone_number: phone_number)
        return nil unless user
        user.is_password?(password) ? user : nil
    end

    def password=(password)
        @password = password
        self.passwor_digest = BCrypt::Password.create(password)
    end

    def is_password?(password)
        BCrypt::Password.new(self.passwor_digest).is_password?(password)
    end

    def reset_session_token!
        generate_unique_session_token
        save!
        self.session_token
    end
    
    private
    
    def ensure_session_token
        generate_unique_session_token unless self.session_token
    end
    
    def new_session_token
        SecureRandom.urlsafe_base64
    end

    def generate_unique_session_token
        self.session_token = new_session_token
        while User.find_by(session_token: self.session_token)
            self.session_token = new_session_token
        end
        self.session_token
    end
end
