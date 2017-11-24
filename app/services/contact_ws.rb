class ContactWS
  include HTTParty
  base_uri 'http://localhost:3000'
end

=begin
# examples (after rake db:seed)

# list contacts
pp ContactWS.get('/contacts').parsed_response
pp ContactWS.get('/contacts?email=dylan.hand@dicki.org&last_name=stokes').parsed_response

# list a single contact
pp ContactWS.get('/contacts/5a177cddf600cb5bf63b9b07').parsed_response

# create a new contact
pp ContactWS.post('/contacts',
                  body: {
                      contact: {
                          first_name: 'John',
                          last_name: 'Liu',
                          phone: '(123)312-3212'
                      }
                  }.to_json,
                  headers: {
                      'Content-Type' => 'application/json'
                  }).parsed_response

# update an existing contact
pp ContactWS.put('/contacts/5a177cddf600cb5bf63b9b07',
                 body: {
                     contact: {
                         first_name: 'David',
                         email: 'abc@gmail.com'
                     }
                 }.to_json,
                 headers: {
                     'Content-Type' => 'application/json'
                 }).parsed_response

# delete an existing contact
pp ContactWS.delete('/contacts/5a177cddf600cb5bf63b9b07').parsed_response
=end