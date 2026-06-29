import Config

config :phoenix, :template_engines, heex: Phoenix.LiveView.HTMLEngine

if config_env() == :dev do
  import_config "dev.exs"
end
