-- Allow an authenticated owner to delete their own newsletter
-- subscription. The original migration only carried SELECT/INSERT/UPDATE
-- policies because the localStorage-backed newsletter store did its own
-- persistence. Now that the frontend calls Supabase directly,
-- unsubscribe() needs a DELETE policy scoped to the owner.

create policy "owners delete newsletter" on public.newsletter_subscriptions
  for delete using (auth.uid() = user_id);
