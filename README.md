# contact-manage

A very simple RESTful API for managing contacts, built on Ruby on Rails and MongoDB.

A contact is a document that contains id, first_name, last_name, phone, and email.

First and last name can never be blank. Phone and email are optional fields and may be blank or not provided at all.

# How to run
1. Make sure you have Ruby on Rails 4.2+ and MongoDB 3.4+ installed.
1. Clone this repo.
1. `mongod`
1. `bundle`
1. `rake db:migrate` (resolve potential db/schema.rb warnings that check for its existence)
1. `rake db:seed` (generate five random documents)
1. `rake db:mongoid:create_indexes`
1. `rails server`

## Client class
A convenient HTTParty client class `ContactWS` is provided to test the capability of the API. But you are free to use any tools that allow you to submit HTTP requests.  

Base URI is at http://localhost:3000

After `rake db:seed`, you can run the following examples with `ContactWS` (substitute the request parameters according to the actual documents stored in your DB) in the Rails console (`rails c`).

### list contacts
```ruby
pp ContactWS.get('/contacts').parsed_response
pp ContactWS.get('/contacts?email=dylan.hand@dicki.org&last_name=stokes').parsed_response
```

### list a single contact
```ruby
pp ContactWS.get('/contacts/5a177cddf600cb5bf63b9b07').parsed_response
```

### create a new contact
```ruby
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
```

### update an existing contact
```ruby
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
```

### delete an existing contact
```ruby
pp ContactWS.delete('/contacts/5a177cddf600cb5bf63b9b07').parsed_response
```

## Rspec
Model and request tests are included in the API. Simply do `rspec` to run all tests.