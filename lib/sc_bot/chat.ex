defmodule ScBot.Chat do
  use GenServer
  require Logger



  def start_link(name) do
    #Logger.info "#{__MODULE__}: "<> inspect(self()) <>" create new chat " <> name
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  defp via_tuple(chat_name) do
    {:via, :gproc, {:n, :l, {:chat, chat_name}}}
  end

  def request(chat_name, message) do
    #Logger.info "#{__MODULE__}: "<> inspect(self()) <>" request " <> chat_name
    GenServer.cast(via_tuple(chat_name), {:request, message})
  end

  def response(pid) do
    GenServer.call(pid, :response)
  end

  def init(state) do
    Logger.info "#{__MODULE__}: "<> inspect(self()) <>" create new chat " <> state
    {:ok, []}
  end

  def handle_cast({:request, message}, state) do
    #Logger.info "CHAT " <> inspect(self()) <> ": requested "

    {:ok, reg}=Regex.compile(Application.get_env(:sc_bot, :atm_command))

    case message[:message] do
      %{message_id: message_id, text: text, chat: %{id: chat_id}} ->
        cond do
          String.match?(text, reg) ->
            state=[%ScBot.Message{chat_id: chat_id, text: dbinfo_task(List.last(String.split(text))), reply_to_message_id: message_id} | state]
          true -> state=[%ScBot.Message{chat_id: chat_id, text: "uncknown cmd: "<>text, reply_to_message_id: message_id} | state]
         end
      _ -> Logger.error "cant parse request"
    end

    {:noreply, state}
  end

  def handle_call(:response, _from, state) do
    #Logger.info "CHAT " <> inspect(self()) <> ": responsed: "
    {:reply, state, []}
  end

  defp dbinfo_task(item) do
    Logger.info "DBINFO: " <> item
    {:ok, pid}=Postgrex.start_link(hostname: Application.get_env(:sc_bot, :db_hostname),
                                   username: Application.get_env(:sc_bot, :db_username),
                                   password: Application.get_env(:sc_bot, :db_password),
                                   database: Application.get_env(:sc_bot, :db_database))
    sql=Application.get_env(:sc_bot, :db_atm_sql) <> "'%#{item}%'"
    %Postgrex.Result{command: :select, columns: ["data"], rows: rows, num_rows: num_rows}=Postgrex.query!(pid, sql, [])
    if num_rows>0 do
      hd(hd(rows))
    else
      "Not find #{item}"
    end
  end
end
