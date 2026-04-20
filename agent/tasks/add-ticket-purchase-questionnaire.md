# Add questionnaire to ticket purchase flow

Implement the questionnaire requirement specified in issue #20
(https://github.com/hanneseklund/MassanApp/issues/20).

When buying tickets, require the user to answer:

- General questions about the user:
  - Gender
  - Country and region of residence
  - Visit type: professional or private
  - If professional: company and role at that company
- Event-relevant questions:
  - Which subjects around the event theme the user is interested in

Integrate this into the existing ticket purchase flow (see completed task
`implement-ticket-purchase-and-my-tickets.md` for prior context). Persist the
answers so they are associated with the ticket / user profile, and consider
whether previously-answered general questions should be pre-filled or skipped
on subsequent purchases.
