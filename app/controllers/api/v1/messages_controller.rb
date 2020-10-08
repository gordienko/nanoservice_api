# frozen_string_literal: true

module Api
  module V1
    class MessagesController < ActionController::API
      include ActionController::HttpAuthentication::Basic::ControllerMethods
      before_action :http_basic_authenticate

      def create
        @message = Message.new(message_params)
        if @message.save
          render json: { messages: 'Message sent for processing', is_success: true,
                        data: { message: @message } }, status: :ok
        else
          render json: { messages: @message.errors.messages, is_success: false, data: {} },
                 status: :unprocessable_entity
        end
      end

      private

      def http_basic_authenticate
        message = { messages: 'Invalid credentials', is_success: false, data: {} }.to_json
        authenticate_or_request_with_http_basic("Nanoservice", message)do |username, password|
          username == Rails.application.credentials.dig(:username) &&
              password == Rails.application.credentials.dig(:password)
        end
      end

      def message_params
        params.permit(:body, dispatches_attributes: %i[id phone messenger_type send_at])
      end
    end
  end
end
