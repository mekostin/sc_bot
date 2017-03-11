defmodule ScBot do
  use Application
  require Logger

  @task_poller ScBot.PollUpdatesTask
  @task_poller_supervisor ScBot.PollUpdatesTask.Supervisor
  @chat_registrator ScBot.ChatRegistry
  @chat_supervisor ScBot.Chat.Supervisor
  @forum ScBot.Forum

  def version do
    {:ok, version}=:application.get_key(:sc_bot, :vsn)
    version
  end

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [
      supervisor(@chat_supervisor, []),
      worker(@chat_registrator, []),
      worker(@forum, []),
      worker(Task, [ScBot.TcpServer, :accept, [elem(Integer.parse(System.get_env("PORT"), 10), 0)]])
    ]

    opts=[strategy: :one_for_one, name: :scbot_main]

    Logger.info "Starting main Supervisor.."
    {:ok, spid}=Supervisor.start_link(children, opts)

    Logger.info "Polling for updates.."
    Task.Supervisor.start_link(name: @task_poller_supervisor, restart: :transient, max_restarts: 0)
    Task.Supervisor.start_child(@task_poller_supervisor, @task_poller, :poll, [0, 0])
    {:ok, spid}
  end
end
