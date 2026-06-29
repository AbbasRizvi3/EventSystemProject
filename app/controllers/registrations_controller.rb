class RegistrationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @event = Event.find(params[:event_id])
    @registrations = policy_scope(@event.registrations).includes(:user)
    authorize Registration
  end

  def create
    @event = Event.find(params[:event_id])
    @registration = @event.registrations.find_or_initialize_by(user: current_user)
    @registration.status = "confirmed"
    authorize @registration
    if @registration.save
      NotificationJob.perform_later(current_user.id, "Registration Confirmed", "You have registered for #{@event.title}.", "registration")
      EventChannel.broadcast_to(@event, { seats_left: @event.capacity - @event.registrations.confirmed.count, capacity: @event.capacity })
      redirect_to @event, notice: "Successfully registered for the event."
    else
      redirect_to @event, alert: @registration.errors.full_messages.join(", ")
    end
  end

  def destroy
    @registration = Registration.find(params[:id])
    authorize @registration
    event_was_full = @registration.event.registrations.confirmed.count >= @registration.event.capacity
    if @registration.update(status: "cancelled")
      WaitlistPromotionJob.perform_later(@registration.event_id) if event_was_full
      EventChannel.broadcast_to(@registration.event, { seats_left: @registration.event.capacity - @registration.event.registrations.confirmed.count, capacity: @registration.event.capacity })
      redirect_to @registration.event, notice: "Registration cancelled."
    else
      redirect_to @registration.event, alert: @registration.errors.full_messages.to_sentence
    end
  end
end
