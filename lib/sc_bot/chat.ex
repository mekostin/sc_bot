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

     case message[:message] do
       %{message_id: message_id, text: text, from: %{id: chat_id, first_name: first_name, last_name: last_name}} ->
          state=[%ScBot.Message{chat_id: chat_id, text: first_name<>" "<>last_name<>" send me: "<>text, reply_to_message_id: message_id} | state]
       _ -> Logger.error "cant parse request"
     end

    {:noreply, state}
  end

 def handle_call(:response, _from, state) do
   Logger.info "CHAT " <> inspect(self()) <> ": responsed: "
   {:reply, state, []}
 end

end
