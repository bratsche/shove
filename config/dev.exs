use Mix.Config

config :shove,
  apns: [
    push_host: "gateway.sandbox.push.apple.com",
    push_port: 2195,
    feedback_host: "feedback.sandbox.push.apple.com",
    feedback_port: 2196,
    certfile: ""
  ]
