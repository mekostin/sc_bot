defmodule ScBot.ChatRegistry do
  use GenServer
  require Logger

  #API
  def start_link(state) do
    Logger.info "#{__MODULE__}: "<> inspect(self()) <>" start_link"
    GenServer.start_link(__MODULE__, [], name: :chat_registrator)
  end

  def process_chats(tasks) do
    Logger.info "#{__MODULE__}." <> inspect(self()) <> " process"
    GenServer.cast(:chat_registrator, {:process_chats, tasks})
  end

  #SERVER
   def init(_) do
     Logger.info "#{__MODULE__}: "<> inspect(self()) <>" init"
     {:ok, []}
   end

   def handle_cast({:process_chats, chat_tasks}, state) do
     Logger.info "#{__MODULE__}: "<> inspect(self()) <>" handle_cast " <>
     Integer.to_string(Enum.count(chat_tasks))

     Enum.map(chat_tasks, fn(task) -> proc_task(task, state) end)

    {:noreply, []}
  end

  defp proc_task(task, state) do
    Logger.info Integer.to_string(task[:message][:chat][:id])
                <> " " <>
                Integer.to_string(task[:message][:message_id])
                <> " " <>
                task[:message][:text]

    chat_id=task[:message][:chat][:id]



    Logger.info "create new chat " <> Integer.to_string(chat_id)
    ScBot.Chat.Supervisor.start_chat(Integer.to_string(chat_id))
    ScBot.Chat.request(Integer.to_string(chat_id), task) 

  end
end
