import Config

config :phoenix, :template_engines, heex: Phoenix.LiveView.HTMLEngine

config :esbuild,
  version: "0.21.0",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../../priv/static/assets/js --external:/fonts/* --external:/images/*),
    cd: Path.expand("../dev/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "4.0.9",
  default: [
    args: ~w(
      --input=dev/assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

if config_env() == :dev do
  import_config "dev.exs"
end
