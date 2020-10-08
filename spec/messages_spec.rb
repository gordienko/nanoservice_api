# frozen_string_literal: true

require 'rails_helper'
messenger_types = Dispatch.messenger_type.values

describe 'sending a message without authentication', type: :request do
  before do
    post '/api/v1/messages', params: { body: Faker::Lorem.sentence(word_count: 20, supplemental: true),
                                       dispatches_attributes: [
                                         { phone: '+79218419858', messenger_type: messenger_types.sample },
                                         { phone: '+79318409858', messenger_type: messenger_types.sample },
                                         { phone: '+79418519158', messenger_type: messenger_types.sample },
                                         { phone: '+79508509258', messenger_type: messenger_types.sample }
                                       ] }
  end
  it 'returns failure messages' do
    expect(JSON.parse(response.body)['messages']).to eq('Invalid credentials')
  end
end

describe 'sending a message with duplicate recipient', type: :request do
  before do
    post '/api/v1/messages', params: { body: Faker::Lorem.sentence(word_count: 20, supplemental: true),
                                       dispatches_attributes: [
                                         { phone: '+79318409858', messenger_type: 'telegram' },
                                         { phone: '+79318409858', messenger_type: 'telegram' }
                                       ] }, headers: http_login
  end
  it 'returns failure messages' do
    expect(JSON.parse(response.body).dig('messages', 'dispatches.phone').first).to eq('uniqueness constraint violated')
  end
end

describe 'sending a message to an unknown messenger', type: :request do
  before do
    post '/api/v1/messages', params: { body: Faker::Lorem.sentence(word_count: 20, supplemental: true),
                                       dispatches_attributes: [
                                         { phone: '+79318429858', messenger_type: 'unknown-messenger' }
                                       ] }, headers: http_login
  end
  it 'returns failure messages' do
    expect(JSON.parse(response.body).dig('messages', 'dispatches.messenger_type').first)
      .to eq('is not included in the list')
  end
end

describe 'sending a scheduled message for the past time', type: :request do
  before do
    post '/api/v1/messages', params: { body: Faker::Lorem.sentence(word_count: 20, supplemental: true),
                                       dispatches_attributes: [
                                         { phone: '+79318401234',
                                           messenger_type: 'viber',
                                           send_at: Time.zone.now - 1.days }
                                       ] }, headers: http_login
  end
  it 'returns failure messages' do
    expect(JSON.parse(response.body).dig('messages', 'dispatches.send_at').first)
      .to eq('must be greater than the current time')
  end
end

describe 'sending a scheduled message for the past time', type: :request do
  before do
    post '/api/v1/messages', params: { body: Faker::Lorem.sentence(word_count: 20, supplemental: true),
                                       dispatches_attributes: [
                                         { phone: '+79318401234',
                                           messenger_type: 'viber',
                                           send_at: Time.zone.now + 1.minutes }
                                       ] }, headers: http_login
  end
  it 'returns a successful message' do
    expect(JSON.parse(response.body)['messages']).to eq('Message sent for processing')
  end
end

describe 'sending a scheduled message for the past time', type: :request do
  before do
    post '/api/v1/messages', params: { dispatches_attributes: [
      { phone: '+79318401234', messenger_type: 'viber', send_at: Time.zone.now + 1.minutes }
    ] }, headers: http_login
  end
  it 'returns failure messages' do
    expect(JSON.parse(response.body).dig('messages', 'body').first).to eq('can\'t be blank')
  end
end

describe 'sending a message to an unimpressive phone', type: :request do
  before do
    post '/api/v1/messages', params: { body: Faker::Lorem.sentence(word_count: 20, supplemental: true),
                                       dispatches_attributes: [
                                         { phone: '+74272220253',
                                           messenger_type: 'viber',
                                           send_at: Time.zone.now + 1.minutes }
                                       ] }, headers: http_login
  end
  it 'returns failure messages' do
    expect(JSON.parse(response.body).dig('messages', 'dispatches.phone').first).to eq('is invalid')
  end
end

describe 'sending a message without a recipient list', type: :request do
  before do
    post '/api/v1/messages', params: { body: Faker::Lorem.sentence(word_count: 20, supplemental: true) },
                             headers: http_login
  end
  it 'returns failure messages' do
    expect(JSON.parse(response.body).dig('messages', 'dispatches').first).to eq('Must have at least one dispatch')
  end
end

describe 'sending a message twice to one recipient', type: :request do
  body = Faker::Lorem.sentence(word_count: 20, supplemental: true)
  phone = '+79218419858'
  messenger_type = 'telegram'
  before do
    2.times do
      post '/api/v1/messages', params: { body: body, dispatches_attributes: [
        { phone: phone, messenger_type: messenger_type }
      ] }, headers: http_login
    end
  end

  it 'returns a failure message' do
    expect(JSON.parse(response.body).dig('messages', 'dispatches.phone').first)
      .to eq("a similar message using #{messenger_type} has already been sent to #{phone}")
  end
end

describe 'sending a message with authentication', type: :request do
  before do
    post '/api/v1/messages', params: { body: Faker::Lorem.sentence(word_count: 20, supplemental: true),
                                       dispatches_attributes: [
                                         { phone: '+79218419858', messenger_type: messenger_types.sample },
                                         { phone: '+79318409858', messenger_type: messenger_types.sample },
                                         { phone: '+79418519158', messenger_type: messenger_types.sample },
                                         { phone: '+79508509258', messenger_type: messenger_types.sample }
                                       ] }, headers: http_login
  end

  it 'returns a successful message' do
    expect(JSON.parse(response.body)['messages']).to eq('Message sent for processing')
  end
end
