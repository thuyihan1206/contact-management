require 'rails_helper'
require 'mongo'

describe Contact, type: :model, orm: :mongoid do
  include_context 'db_cleanup'

  before(:each) do
    @contact = FactoryGirl.create(:contact)
  end
  let(:contact) { Contact.find @contact.id }

  context 'valid contacts' do

    it 'find contact' do
      expect(contact).to be_persisted
      expect(contact).to_not be_nil
      expect(contact.first_name).to eq(@contact.first_name)
      expect(contact.last_name).to eq(@contact.last_name)
      expect(contact.phone).to eq(@contact.phone)
      expect(contact.email).to eq(@contact.email)
    end

    it 'update contact' do
      contact.update(first_name: 'John')
      expect(contact.first_name).to eq('John')
    end

    it 'delete contact' do
      expect(Contact.where(id: @contact.id).exists?).to be true
      contact.destroy
      expect(Contact.where(id: @contact.id).exists?).to be false
    end

  end

  context 'invalid contacts' do
    let(:invalid_contact) { FactoryGirl.build(:contact, first_name: '') }

    it 'unable to create contact' do
      expect(invalid_contact.validate).to be false
      expect(invalid_contact.errors.messages).to include(first_name: ['can\'t be blank'])
    end

    it 'unable to update contact' do
      contact.update(phone: '123-123-123d')
      expect(contact.validate).to be false
      expect(contact.errors.messages).to include(phone: ['is invalid'])

      contact.update(email: 'a@b@c.com')
      expect(contact.validate).to be false
      expect(contact.errors.messages).to include(email: ['is invalid'])
    end

  end
end