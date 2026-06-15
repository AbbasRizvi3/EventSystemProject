import consumer from "channels/consumer"

let eventSubscription = null

function setupEventChannel() {
  if (eventSubscription) {
    eventSubscription.unsubscribe()
    eventSubscription = null
  }

  const eventCard = document.querySelector("[data-event-id]")
  const eventId = eventCard ? eventCard.dataset.eventId : null

  if (!eventId) return

  eventSubscription = consumer.subscriptions.create({ channel: "EventChannel", event_id: eventId }, {
    connected() {},
    disconnected() {},
    received(data) {
      if (data.seats_left !== undefined) {
        const seatsEl = document.getElementById("seats-available")
        if (seatsEl) seatsEl.innerText = data.seats_left + " / " + data.capacity + " spots available"

        fetch(window.location.href, { headers: { "Accept": "text/html" } })
          .then(r => r.text())
          .then(html => {
            const doc = new DOMParser().parseFromString(html, "text/html")
            const newActions = doc.getElementById("event-actions")
            const currentActions = document.getElementById("event-actions")
            if (newActions && currentActions) currentActions.innerHTML = newActions.innerHTML
          })
      }

      if (data.type === "cancelled") {
        const statusEl = document.getElementById("event-status")
        if (statusEl) {
          statusEl.innerText = "Cancelled"
          statusEl.className = "badge bg-danger fs-6"
        }
        const actionsEl = document.getElementById("event-actions")
        if (actionsEl) actionsEl.innerHTML = "<span class='text-muted'>This event has been cancelled.</span>"
      }
    }
  })
}

document.addEventListener("turbo:load", setupEventChannel)
