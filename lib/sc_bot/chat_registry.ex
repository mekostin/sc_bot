defmodule ScBot.ChatRegistry do
  use GenServer
  require Logger

  #API
  def start_link do
    #Logger.info "#{__MODULE__}: "<> inspect(self()) <>" start_link"
    GenServer.start_link(__MODULE__, [], name: :chat_registrator)
  end

  def process_chats(tasks) do
    #Logger.info "#{__MODULE__}." <> inspect(self()) <> " process"
    GenServer.call(:chat_registrator, {:process_chats, tasks})
  end

  def get_answers do
    GenServer.call(:chat_registrator, :get_answers)
  end

  #SERVER
  def init(_) do
    #Logger.info "#{__MODULE__}: "<> inspect(self()) <>" init"
    {:ok, []}
  end

  def handle_call({:process_chats, chat_tasks}, _from, state) do
    #Logger.info "#{__MODULE__}: "<> inspect(self()) <>" handle_cast " <>
    {:reply,
      Enum.reduce(chat_tasks, [], fn(task, ack) ->
                                      proc_task(task) ++ ack
                                  end), []}
  end

  def handle_call(:get_answers, _from, state) do
    #Logger.info "#{__MODULE__}: "<> inspect(self()) <>" handle_call "
    {:reply, ScBot.Chat.Supervisor.get_answers, []}
  end

  def proc_task(task) do
    case task[:message] do
      %{message_id: message_id, text: text, chat: %{id: chat_id}} ->
        {:ok, reg}=Regex.compile(Application.get_env(:sc_bot, :chat_password))
        if :gproc.where({:n, :l, {:chat, Integer.to_string(chat_id)}})==:undefined do
          cond do
            String.match?(text, reg) ->
              ScBot.Chat.Supervisor.start_chat(Integer.to_string(chat_id))
              [%ScBot.Message{chat_id: chat_id, text: "you succefull authorized! enter commands", reply_to_message_id: message_id}]
            true ->
              [%ScBot.Message{chat_id: chat_id, text: "Please Enter chat password", reply_to_message_id: message_id}]
          end
        else
          ScBot.Chat.request(Integer.to_string(chat_id), task)
          []
        end

      _ ->
          Logger.error "cant parse request"
          []
    end
  end
end
