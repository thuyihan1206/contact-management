require 'rails_helper'

RSpec.describe 'Contact API', type: :request do
  include_context 'db_cleanup'
  let(:payload) { parsed_body }

  context 'requests a list of contacts' do
    let!(:resources) { (1..5).map { |_idx| FactoryGirl.create(:contact) } }

    it 'returns all contact instances' do
      jget send('contacts_path'), {}, 'Accept' => 'application/json'
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json')

      expect(payload.count).to eq(resources.count)
      last_name_from_payload = payload.map { |f| f['last_name'] }
      last_name_from_resources = resources.map { |f| f[:last_name] }
      expect(same_set?(last_name_from_payload, last_name_from_resources)).to be true
    end

    it 'returns a specific contact instance' do
      first_name = resources[2].first_name
      jget send('contacts_path'), { first_name: first_name }, 'Accept' => 'application/json'
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json')

      expect(payload.count).to eq(1)
      expect(payload[0]['phone']).to eq(resources[2][:phone])

      jget send('contacts_path'), { first_name: first_name },
           'If-Modified-Since' => response.headers['Last-Modified']
      expect(response).to have_http_status(:not_modified)
    end

    it 'returns no contact instance if not matched' do
      jget send('contacts_path'), { first_name: 'random' }, 'Accept' => 'application/json'
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json')

      expect(payload['success']['full_messages'][0]).to include('no record found')
    end

  end

  context 'request a specific contact' do
    let(:resource) { FactoryGirl.create(:contact) }
    let(:bad_id) { 1234567890 }

    it 'returns contact when using correct ID' do
      jget send('contact_path', resource.id)
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json')

      expect(payload).to have_key('first_name')
      expect(payload).to have_key('last_name')
      expect(payload['phone']).to eq(resource.phone)
      expect(payload['email']).to eq(resource.email)
    end

    it 'returns not found when using incorrect ID' do
      jget send('contact_path', bad_id)
      expect(response).to have_http_status(:not_found)
      expect(response.content_type).to eq('application/json')

      expect(payload['errors']['full_messages'][0]).to include('cannot', bad_id.to_s)
    end

  end

  context 'create a new contact' do
    let(:resource_state) { { contact: FactoryGirl.attributes_for(:contact) } }
    let(:resource_id)    { payload['_id']['$oid'] }

    it 'can create a valid contact' do
      jpost send('contacts_path'), resource_state
      expect(response).to have_http_status(:created)
      expect(response.content_type).to eq('application/json')

      expect(payload).to have_key('_id')
      expect(payload['email']).to eq(resource_state[:contact][:email])

      # verify we can locate the created instance in DB
      jget send('contact_path', resource_id)
      expect(response).to have_http_status(:ok)
      expect(Contact.find(resource_id).email).to eq(resource_state[:contact][:email])
    end

    it 'unable to create an invalid contact' do
      resource_state[:contact][:last_name] = ''
      jpost send('contacts_path'), resource_state
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.content_type).to eq('application/json')

      expect(payload['errors']['last_name']).to include('can\'t be blank')
    end

  end

  context 'update and delete an existing contact' do
    let(:resource) do
      jpost send('contacts_path'), contact: FactoryGirl.attributes_for(:contact)
      expect(response).to have_http_status(:created)
      parsed_body
    end
    let(:new_state)      { { contact: FactoryGirl.attributes_for(:contact) } }
    let(:resource_id)    { resource['_id']['$oid'] }
    let(:bad_id)         { 1234567890 }

    it 'can update a valid contact' do
      # change to new state
      jput send('contact_path', resource_id), new_state
      expect(response).to have_http_status(:ok)

      # verify email is not yet the new email
      expect(resource['email']).to_not eq(new_state[:contact][:email])

      # verify we can locate the updated instance in DB
      expect(Contact.find(resource_id).email).to eq(new_state[:contact][:email])
    end

    it 'unable to update an invalid contact' do
      new_state[:contact][:phone] = '123-123-1234-123'
      jput send('contact_path', resource_id), new_state
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.content_type).to eq('application/json')

      expect(payload['errors']['phone']).to include('is invalid')
    end

    it 'can delete a contact' do
      jhead send('contact_path', resource_id)
      expect(response).to have_http_status(:ok)

      jdelete send('contact_path', resource_id)
      expect(response).to have_http_status(:ok)

      jhead send('contact_path', resource_id)
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found when using incorrect ID to delete' do
      jdelete send('contact_path', bad_id)
      expect(response).to have_http_status(:not_found)
      expect(response.content_type).to eq('application/json')

      expect(payload['errors']['full_messages'][0]).to include('cannot', bad_id.to_s)
    end

  end
end
