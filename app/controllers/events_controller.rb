class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: %i[ show edit update destroy cancel ]

  def index
    @events = policy_scope(Event).page(params[:page]).per(10)
    @registered_event_ids = current_user.registrations.confirmed.pluck(:event_id).to_set
    @waitlisted_event_ids = current_user.wait_list_entries.pluck(:event_id).to_set
  end

  def show
    authorize @event
  end

  def new
    @event = Event.new
    authorize @event
  end

  def edit
    authorize @event
  end

  def create
    @event=current_user.events.build(event_params)
    authorize @event

    if @event.save
      redirect_to @event, notice: "Event was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @event
    if @event.update(event_params)
      EventChannel.broadcast_to(@event, { seats_left: @event.capacity - @event.registrations.confirmed.count, capacity: @event.capacity })
      redirect_to @event, notice: "Event was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @event
    @event.destroy
    redirect_to events_url, notice: "Event was successfully destroyed."
  end

  def cancel
  authorize @event
  @event.update(status: "cancelled")
  @event.attendees.each do |user|
    NotificationJob.perform_later(user.id, "Event Cancelled", "#{@event.title} has been cancelled.", "cancellation")
  end
  @event.waitlisted_users.each do |user|
    NotificationJob.perform_later(user.id, "Event Cancelled", "#{@event.title} has been cancelled.", "cancellation")
  end
  EventChannel.broadcast_to(@event, { type: "cancelled" })
  redirect_to @event, notice: "Event has been cancelled."
  end

  def registered_events
    authorize Event, :registered_events?
    @events = current_user.registered_events.page(params[:page]).per(10)
  end

  def waitlisted_events
    authorize Event, :waitlisted_events?
    @events = current_user.waitlisted_events.page(params[:page]).per(10)
  end

  def created_events
    authorize Event, :created_events?
    @events = current_user.events.page(params[:page]).per(10)
  end

  private
    def set_event
      @event = Event.find(params[:id])
    end

    def event_params
      params.require(:event).permit(:title, :description, :location, :start_time, :end_time, :capacity, :status)
    end
end
