class Dispatch < ApplicationRecord
  extend Enumerize
  belongs_to :message

  enumerize :messenger_type, in: { viber: 0, telegram: 1, whatsapp: 2 }, predicates: true, scope: true
  enumerize :status, in: { pending: 0, process: 1, sent: 2, error: 3 }, predicates: true, scope: true

  default_scope -> { order(id: :desc) }

  validates :messenger_type, :status, presence: true
  validates :phone, phone: { types: [:mobile] }
  validate :validate_send_at, on: :create
  validate :validate_phone, on: :create
  validate :validate_repeat, on: :create

  after_create_commit :send_message

  private

  def validate_phone
    if message.dispatches.to_a.select { |a| a[:messenger_type] == messenger_type && a[:phone] == phone }.length > 1
      errors.add(:phone, 'uniqueness constraint violated')
    end
  end

  def validate_send_at
    if send_at && send_at <= Time.zone.now
      errors.add(:send_at, 'must be greater than the current time')
    end
  end

  def validate_repeat
    check_message = Message.where(body: message.body).first
    if check_message and check_message.dispatches.where(messenger_type: messenger_type, phone: phone).count > 0
      errors.add :phone, "a similar message using #{messenger_type} has already been sent to #{phone}"
    end
  end

  # Отправка процесса в очередь задач
  def send_message
    "Send#{messenger_type.capitalize}MessageJob".constantize.
        set(wait_until: (send_at? ? send_at : Time.zone.now)).perform_later(self)
  end
end
