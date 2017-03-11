defmodule ScBot.Forum do
  use GenServer
  require Logger

  defmodule State, do: defstruct responses: [], id_msg: 0

  #API
  def start_link do
    GenServer.start_link(__MODULE__, [], name: :forum)
  end

  def get_answers do
    GenServer.call(:forum, :get_answers)
  end

  #SERVER
  def init(_) do
    {:ok, %State{responses: [], id_msg: 0}}
  end

  def handle_call(:get_answers, _from, state) do
    state=check_forum(state)
    IO.inspect state
    {:reply, Map.get(state, :responses), %State{state | responses: []}}
  end

  defp check_forum(state) do
    {:ok, pid}=Mysqlex.Connection.start_link(hostname: Application.get_env(:sc_bot, :forum_hostname),
                                  username: Application.get_env(:sc_bot, :forum_username),
                                  password: Application.get_env(:sc_bot, :forum_password),
                                  database: Application.get_env(:sc_bot, :forum_database))

    if Map.get(state, :id_msg)==0 do
      sql=Application.get_env(:sc_bot, :forum_mess_id_sql)
      {:ok, %Mysqlex.Result{columns: ["data"], rows: rows}}=Mysqlex.Connection.query!(pid, sql, [])
      state=%State{state | id_msg: elem(hd(rows), 0)}
#      state=%State{state | id_msg: 103575}
      Logger.info "Get id_msg=" <> Integer.to_string(Map.get(state, :id_msg))
    end

    sql=Application.get_env(:sc_bot, :forum_messages_sql) <> Integer.to_string(Map.get(state, :id_msg))
    #Logger.info sql

    {:ok, %Mysqlex.Result{columns: ["data", "id_msg"], rows: rows, num_rows: num_rows}}=Mysqlex.Connection.query!(pid, sql, [])
    Process.unlink(pid)
    Process.exit(pid, :kill)

    chat_id=Application.get_env(:sc_bot, :forum_chat_id)

    cond do
      num_rows>0 ->
         state=%State{state | responses: Enum.reduce(rows, [],
                                        fn(x, acc) -> [%ScBot.Message{
                                              chat_id: chat_id,
                                              text: "<pre>" <> (elem(x, 0) |> HtmlSanitizeEx.strip_tags) <> "</pre>"
                                                                            } | acc]  end)}
         %State{state | id_msg: elem(Enum.max_by(rows, fn(x)-> elem(x, 1) end),1)}
      true -> state
    end
  end

end
