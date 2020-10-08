# frozen_string_literal: true

class Message < ApplicationRecord
  has_many :dispatches, inverse_of: :message, dependent: :destroy
  accepts_nested_attributes_for :dispatches
  validates :body, presence: true
  validate :at_least_one_dispatches
  default_scope -> { order(id: :desc) }

  def as_json(_options = {})
    super(include: :dispatches)
  end

  private

  def at_least_one_dispatches
    errors.add :dispatches, 'Must have at least one dispatch' unless dispatches.length.positive?
  end
end
