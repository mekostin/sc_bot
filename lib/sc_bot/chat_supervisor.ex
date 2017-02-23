defmodule ScBot.Chat.Supervisor do
  use Supervisor

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

end
