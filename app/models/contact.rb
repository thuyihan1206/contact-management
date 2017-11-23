class Contact
  include Mongoid::Document
  include Mongoid::Timestamps

  field :first_name, type: String
  field :last_name, type: String
  field :phone, type: String
  field :email, type: String

  auto_strip_attributes :first_name, :last_name, :phone, :email # removes whitespaces from the beginning and the end of string

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_format_of :phone, with: /\A(?:\+?0?1\s?)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}\Z/ # assuming U.S. format
  validates_format_of :email, with: /\A[^@\s]+@(?:[-a-z0-9]+\.)+[a-z]{2,}\Z/i
end
