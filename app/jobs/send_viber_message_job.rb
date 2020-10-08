# frozen_string_literal: true

class SendViberMessageJob < ApplicationJob
  queue_as :viber

  def perform(dispatch)
    implementation_method_sending_to_viber(dispatch)
  end

  private

  def implementation_method_sending_to_viber(dispatch)
    dispatch.update!(status: :process)
    delay = rand
    sleep delay
    if delay > 0.8
      dispatch.update!(status: :error)
      raise 'There was an error sending message to Viber'
    else
      dispatch.update!(status: :sent)
    end
  end
end
