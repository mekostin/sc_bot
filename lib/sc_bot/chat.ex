defmodule ScBot.Chat do
  use GenServer
  require Logger

  def start_link(name) do
    Logger.info "#{__MODULE__}: "<> inspect(self()) <>" start_link " <> name
    GenServer.start_link(__MODULE__, [], name: via_tuple(name))
  end

  defp via_tuple(chat_name) do
    {:via, :gproc, {:n, :l, {:chat, chat_name}}}
  end

  def request(chat_name, message) do
    Logger.info "#{__MODULE__}: "<> inspect(self()) <>" request " <> chat_name
    GenServer.cast(via_tuple(chat_name), {:request, message})
  end

  def response(pid) do
    GenServer.call(pid, :response)
  end

  def init(state) do
    Logger.info "#{__MODULE__}: "<> inspect(self()) <>" init "
    {:ok, state}
  end

  def handle_cast({:request, message}, state) do
    Logger.info "CHAT " <> inspect(self()) <> ": requested "
     <> message[:message][:text]
    {:noreply, [message[:message][:text] | state]}
  end

 def handle_call(:response, _from, state) do
   Logger.info "CHAT " <> inspect(self()) <> ": responsed"
   {:reply, state, state}
 end

end
