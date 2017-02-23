defmodule ScBot do
  use Application
  require Logger

  @task_poller ScBot.PollUpdatesTask
  @task_poller_supervisor ScBot.PollUpdatesTask.Supervisor
  @chat_registrator ScBot.ChatRegistry
  @chat_supervisor ScBot.Chat.Supervisor

  def version do
    {:ok, version}=:application.get_key(:sc_bot, :vsn)
    version
  end

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [
      supervisor(@chat_supervisor, []),
      worker(@chat_registrator, [%{}])
    ]

    opts=[strategy: :one_for_one, name: :scbot_main]

    Logger.info "Starting main Supervisor.."
    Supervisor.start_link(children, opts)

    Logger.info "Polling for updates.."
    Task.Supervisor.start_link(name: @task_poller_supervisor, restart: :transient, max_restarts: 0)
    Task.Supervisor.start_child(@task_poller_supervisor, @task_poller, :poll, [0])

  end
end
