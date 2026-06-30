# dev/seeds.exs

# Seeds realistic volume of data for visually testing the dashboard —
# pagination, table density, empty/loading states, etc.

# Run with: mix run dev/seeds.exs


import Ecto.Query


alias HawkEx.Billing.{Plan, Feature, PlanFeature, Subscription}
alias HawkEx.Audit.Log
alias HawkExDev.Repo

# ----Clear existing data------------------------------------------------------------

Repo.delete_all(Log)
Repo.delete_all(Subscription)
Repo.delete_all(PlanFeature)
Repo.delete_all(Feature)
Repo.delete_all(Plan)

# ----Plans------------------------------------------------------------

plans =
  [
    %{name: "free", display_name: "Free", trial_days: 0, status: "active"},
    %{name: "pro", display_name: "Pro", trial_days: 14, status: "active"},
    %{name: "enterprise", display_name: "Enterprise", trial_days: 30, status: "active"}
  ]
  |> Enum.map(fn attrs ->
    %Plan{}
    |> Plan.changeset(attrs)
    |> Repo.insert!()
  end)

[free_plan, pro_plan, enterprise_plan] = plans

# ----Features + Plan Features------------------------------------------------------------

features =
  [
    %{key: "export_csv", feature_type: "boolean", description: "Export data as CSV"},
    %{key: "api_calls", feature_type: "limit", description: "Monthly API call limit"},
    %{key: "team_members", feature_type: "limit", description: "Team seats"}
  ]
  |> Enum.map(fn attrs ->
    %Feature{}
    |> Feature.changeset(attrs)
    |> Repo.insert!()
  end)

[export_csv, api_calls, team_members] = features

plan_feature_values = [
  {free_plan, export_csv, "false"},
  {free_plan, api_calls, "500"},
  {free_plan, team_members, "1"},
  {pro_plan, export_csv, "true"},
  {pro_plan, api_calls, "10000"},
  {pro_plan, team_members, "10"},
  {enterprise_plan, export_csv, "true"},
  {enterprise_plan, api_calls, "unlimited"},
  {enterprise_plan, team_members, "unlimited"}
]

Enum.each(plan_feature_values, fn {plan, feature, value} ->
  %PlanFeature{}
  |> PlanFeature.changeset(%{plan_id: plan.id, feature_id: feature.id, value: value})
  |> Repo.insert!()
end)

# ------Subscriptions----------------------------------------------------------

company_names = [
  "acme-co", "globex", "initech", "umbrella", "hooli", "stark-industries",
  "wayne-enterprises", "soylent", "cyberdyne", "tyrell-corp", "aperture",
  "massive-dynamic", "oscorp", "buy-n-large", "weyland-yutani", "vandelay",
  "pied-piper", "dunder-mifflin", "gringotts", "wonka-industries",
  "abstergo", "rekall", "monsters-inc", "prestige-worldwide", "spacely-sprockets"
]

statuses_by_weight = [
  {"active", 60},
  {"trialing", 15},
  {"past_due", 10},
  {"canceled", 15}
]

weighted_status = fn ->
  total = Enum.reduce(statuses_by_weight, 0, fn {_, w}, acc -> acc + w end)
  roll = :rand.uniform(total)

  {status, _} =
    Enum.reduce_while(statuses_by_weight, {nil, roll}, fn {status, weight}, {_, remaining} ->
      if remaining <= weight do
        {:halt, {status, 0}}
      else
        {:cont, {nil, remaining - weight}}
      end
    end)

  status
end

subscriptions =
  company_names
  |> Enum.map(fn name ->
    plan = Enum.random(plans)
    status = weighted_status.()
    days_ago = :rand.uniform(180)
    inserted_at =
      DateTime.utc_now()
      |> DateTime.add(-days_ago, :day)
      |> DateTime.truncate(:second)

    account_id = Ecto.UUID.generate()

    subscription =
      %Subscription{}
      |> Subscription.changeset(%{
        account_id: account_id,
        plan_id: plan.id,
        status: status,
        current_period_start: inserted_at,
        current_period_end: DateTime.add(inserted_at, 30, :day),
        trial_ends_at: if(status == "trialing", do: DateTime.add(inserted_at, plan.trial_days, :day)),
        canceled_at: if(status == "canceled", do: DateTime.add(inserted_at, 20, :day))
      })
      |> Repo.insert!()

    # Backfill inserted_at directly since changeset timestamps() always uses now()
    {1, _} =
      Repo.update_all(
        from(s in Subscription, where: s.id == ^subscription.id),
        set: [inserted_at: inserted_at]
      )

    %{account_name: name, account_id: account_id, subscription: subscription, plan: plan}
  end)

IO.puts("Seeded #{length(subscriptions)} subscriptions")

# ---Audit Logs-------------------------------------------------------------

actions = [
  "subscription.created",
  "subscription.canceled",
  "subscription.plan_changed",
  "settings.updated",
  "team_member.invited",
  "team_member.removed",
  "csv.export.completed",
  "csv.export.failed",
  "api_key.created",
  "api_key.revoked"
]

actor_emails = [
  "jane@acme.co", "bob@globex.com", "alice@initech.com",
  "dev@hooli.com", "admin@stark.io", nil  # nil = system action
]

audit_entries =
  for _ <- 1..220 do
    %{account_name: name, account_id: account_id} = Enum.random(subscriptions)
    action = Enum.random(actions)
    actor_email = Enum.random(actor_emails)
    minutes_ago = :rand.uniform(60 * 24 * 30)

    inserted_at =
      DateTime.utc_now()
      |> DateTime.add(-minutes_ago, :minute)
      |> DateTime.truncate(:second)

    %{
      id: Ecto.UUID.generate(),
      actor_id: if(actor_email, do: Ecto.UUID.generate()),
      actor_type: if(actor_email, do: "User"),
      action: action,
      resource_id: account_id,
      resource_type: "account",
      metadata: %{account_name: name, actor_email: actor_email},
      inserted_at: inserted_at
    }
  end
  |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime})

Repo.insert_all(Log, audit_entries)

IO.puts("Seeded #{length(audit_entries)} audit log entries")
IO.puts("\nDone. Run `mix dev` and visit /hawk_ex to see seeded data.")
