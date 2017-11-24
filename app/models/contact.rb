class Contact
  include Mongoid::Document
  include Mongoid::Timestamps

  field :first_name, type: String
  field :last_name, type: String
  field :phone, type: String
  field :email, type: String

  PHONE_REGEXP = /\A(?:\+?0?1\s?)?\(?(\d{3})\)?[\s.-]?(\d{3})[\s.-]?(\d{4})\Z/ # assuming U.S. format
  EMAIL_REGEXP = /\A[^@\s]+@(?:[-a-z0-9]+\.)+[a-z]{2,}\Z/i

  index({ first_name: 1, last_name: 1 })

  strip_attributes # removes whitespaces from the beginning and the end of string

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_format_of :phone, with: PHONE_REGEXP, allow_blank: true
  validates_format_of :email, with: EMAIL_REGEXP, allow_blank: true

  before_save :standardize_phone_format

  def self.standardize_phone_format(phone)
    match_data = phone.match(PHONE_REGEXP)
    [match_data[1], match_data[2], match_data[3]].join('-') if match_data
  end

  private

  def standardize_phone_format
    self.phone = self.class.standardize_phone_format(phone) if phone
  end

end
