class SendTelegramMessageJob < ApplicationJob
  queue_as :telegram

  def perform(dispatch)
    implementation_method_sending_to_telegram(dispatch)
  end

  private

  def implementation_method_sending_to_telegram(dispatch)
    dispatch.update!(status: :process)
    delay = rand
    sleep delay
    if delay > 0.8
      dispatch.update!(status: :error)
      raise 'There was an error sending message to Telegram'
    else
      dispatch.update!(status: :sent)
    end
  end
end
