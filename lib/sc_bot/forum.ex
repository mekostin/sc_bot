defmodule ScBot.Forum do
  use GenServer
  require Logger

  #API
  def start_link do
    GenServer.start_link(__MODULE__, [], name: :forum)
  end

  def get_answers do
    GenServer.call(:forum, :get_answers)
  end

  #SERVER
  def init(_) do
    {:ok, []}
  end

  def handle_call(:get_answers, _from, state) do
    {:reply, [], state}
  end

  defp check_forum(state) do
    {:ok, pid}=Mysqlex.start_link(hostname: Application.get_env(:sc_bot, :forum_hostname),
                                  username: Application.get_env(:sc_bot, :forum_username),
                                  password: Application.get_env(:sc_bot, :forum_password),
                                  database: Application.get_env(:sc_bot, :forum_database))
    %Postgrex.Result{command: :select, columns: ["data"], rows: rows, num_rows: num_rows}=Mysqlex.query!(pid, sql, [])
    Process.unlink(pid)
    Process.exit(pid, :kill)

    cond do
      num_rows>0 -> Enum.reduce(rows, , )
      true       -> "Not found!"
    end


  end

end
