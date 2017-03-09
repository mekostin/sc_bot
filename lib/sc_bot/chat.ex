defmodule ScBot.Chat do
  use GenServer
  require Logger



  defmodule State, do: defstruct responses: [], tasks: []


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
    {:ok, %State{responses: [], tasks: []}}
  end

  # {:ok, atm_info_reg}=Regex.compile(Application.get_env(:sc_bot, :atm_info_command))
  # {:ok, atm_status_reg}=Regex.compile(Application.get_env(:sc_bot, :atm_status_command))
  # {:ok, tr_info_reg}=Regex.compile(Application.get_env(:sc_bot, :tr_info_command))
  # {:ok, tr_status_reg}=Regex.compile(Application.get_env(:sc_bot, :tr_status_command))

  # cond do
  #   String.match?(text, atm_info_reg) ->
  #     responses=[%ScBot.Message{chat_id: chat_id, text: atm_info_task(List.last(String.split(text))), reply_to_message_id: message_id} | responses]
  #   String.match?(text, ~r/^help$/) ->
  #     responses=[%ScBot.Message{chat_id: chat_id, text: Application.get_env(:sc_bot, :help_command), reply_to_message_id: message_id} | responses]
  #   true -> responses=[%ScBot.Message{chat_id: chat_id, text: "uncknown cmd: "<>text, reply_to_message_id: message_id} | responses]
  #  end

  def handle_cast({:request, message}, state) do
    #Logger.info "CHAT " <> inspect(self()) <> ": requested "

    responses=Map.get(state, :responses)
    case message[:message] do
      %{message_id: message_id, text: text, chat: %{id: chat_id}} ->
        cmd=String.split(text, " ")
        responses=[%ScBot.Message{chat_id: chat_id, text: command(hd(cmd), hd((tl(cmd)))), reply_to_message_id: message_id} | responses]
        state=%State{state | responses: responses}
      _ -> Logger.error "cant parse request"
    end

    {:noreply, state}
  end

  def handle_call(:response, _from, state) do
    #Logger.info "CHAT " <> inspect(self()) <> ": responsed: "
    {:reply, Map.get(state, :responses), %State{state | responses: []}}
  end

############## COMMANDS #######################################################
  defp command("help", _), do: Application.get_env(:sc_bot, :help_command)
  defp command("info", param), do: get_item_info(Application.get_env(:sc_bot, :info_database), "bot.v_i", param)
  defp command("status", param), do: get_item_info(Application.get_env(:sc_bot, :status_database), "bot.v_s", param)
  defp command(_,_), do: "uncknown cmd, please use <b>help</b>"
###############################################################################

  defp get_item_info(database, table, param) do
    {:ok, item_reg}=Regex.compile(Application.get_env(:sc_bot, :item_regex))
    cond do
      String.match?(param, item_reg) ->
        t=hd(Regex.split(~r{_}, param))
        select_sql(database, "select data from #{table}#{t} where item=upper('#{param}') LIMIT 1")
      true -> command(nil, nil)
    end
  end

  defp select_sql(database, sql) do
    #Logger.info sql
    {:ok, pg_pid}=Postgrex.start_link(hostname: Application.get_env(:sc_bot, :db_hostname),
                                   username: Application.get_env(:sc_bot, :db_username),
                                   password: Application.get_env(:sc_bot, :db_password),
                                   database: database)
    %Postgrex.Result{command: :select, columns: ["data"], rows: rows, num_rows: num_rows}=Postgrex.query!(pg_pid, sql, [])
    Process.unlink(pg_pid)
    Process.exit(pg_pid, :kill)
    
    cond do
      num_rows>0 -> hd(hd(rows))
      true       -> "Not found!"
    end
  end
end
