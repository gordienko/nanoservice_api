# frozen_string_literal: true

Rails.application.routes.draw do
  require 'sidekiq/web'
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == Rails.application.credentials.dig(:username) &&
      password == Rails.application.credentials.dig(:password)
  end
  mount Sidekiq::Web => '/sidekiq'

  namespace :api do
    namespace :v1 do
      resources :messages, only: [:create]
    end
  end
end
