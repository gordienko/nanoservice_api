class SendWhatsappMessageJob < ApplicationJob
  queue_as :whatsapp

  def perform(dispatch)
    implementation_method_sending_to_whatsapp(dispatch)
  end

  private

  def implementation_method_sending_to_whatsapp(dispatch)
    dispatch.update!(status: :process)
    delay = rand
    sleep delay
    if delay > 0.8
      dispatch.update!(status: :error)
      raise 'There was an error sending message to Whatsapp'
    else
      dispatch.update!(status: :sent)
    end
  end
end
