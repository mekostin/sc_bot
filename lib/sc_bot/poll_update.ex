defmodule ScBot.PollUpdatesTask do
  require Logger

  defp token, do: Application.get_env(:sc_bot, :bot_token)

  def poll(last_update_id) do
    update_id=0
    Logger.info "Poll TelegramBot #{last_update_id}"

    bot="https://api.telegram.org/bot" <> token
    url=bot <> "/getUpdates"

    if last_update_id != 0 do
      Logger.info "last_update_id: #{last_update_id}"
      url=url <> "?offset=" <> Integer.to_string(last_update_id)
    end

    Logger.info "url: #{url}"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        IO.puts body
        case Poison.decode body, keys: :atoms do
          {:ok, %{ok: true, result: []}} ->
            Logger.warn "Empty data"
          {:ok, %{ok: true, result: result}} ->
            last_update=result |> List.last
            update_id=last_update[:update_id]
            ScBot.ChatRegistry.process_chats(result)
        end
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        Logger.warn  "Not found " <> url
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error reason
    end

    if update_id !=0 do
      last_update_id=update_id+1
    end

    Enum.each(ScBot.ChatRegistry.get_answers, fn(%ScBot.Message{chat_id: chat_id, text: text, reply_to_message_id: reply_to_message_id}) ->
      surl=bot <> "/sendMessage?"
                        <> "chat_id=" <> Integer.to_string(chat_id)
                        <> "&reply_to_message_id=" <> Integer.to_string(reply_to_message_id)
                        <> "&text=\"" <> text <> "\""
      Logger.info "HTTPSend: " <> surl
      HTTPoison.get(surl)
     end)

   :timer.sleep(5000)
    poll(last_update_id)
  end
end
