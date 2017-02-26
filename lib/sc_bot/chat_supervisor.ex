defmodule ScBot.Chat.Supervisor do
  use Supervisor
  require Logger

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: :chat_supervisor)
  end

  def init(_) do
    children = [
      worker(ScBot.Chat, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  def start_chat(name) do
    Supervisor.start_child(:chat_supervisor, [name])
  end

  def get_answers do
    Enum.reduce(Supervisor.which_children(:chat_supervisor), [],
      fn({id, pid, type, modules}, ack) ->
        ScBot.Chat.response(pid) ++ ack
      end)
  end

end
