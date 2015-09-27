use Mix.Config

config :shove,
  apns: [
    host: "gateway.push.apple.com",
    port: 2195,
    feedback_host: "feedback.push.apple.com",
    feedback_port: 2196
  ]
