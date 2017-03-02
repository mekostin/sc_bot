defmodule ScBot.PollUpdatesTask do
  require Logger

  @post_headers %{"Content-type" => "application/x-www-form-urlencoded"}

  defp token, do: Application.get_env(:sc_bot, :bot_token)
  defp bot, do: "https://api.telegram.org/bot" <> token

  def poll(last_update_id) do
    update_id=0
#    Logger.info "Poll TelegramBot #{last_update_id}"

    url=bot <> "/getUpdates"

    if last_update_id != 0 do
#      Logger.info "last_update_id: #{last_update_id}"
      url=url <> "?offset=" <> Integer.to_string(last_update_id)
    end

#    Logger.info "url: #{url}"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Poison.decode body, keys: :atoms do
          {:ok, %{ok: true, result: []}} ->
            "Empty data"
          {:ok, %{ok: true, result: result}} ->
            last_update=result |> List.last
            update_id=last_update[:update_id]
            now_answers=ScBot.ChatRegistry.process_chats(result)
            sendMessage(now_answers)
        end
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        Logger.warn  "Not found " <> url
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error reason
    end

    if update_id !=0 do
      last_update_id=update_id+1
    end

    sendMessage(ScBot.ChatRegistry.get_answers)

   :timer.sleep(1000)
    poll(last_update_id)
  end

  defp sendMessage(messages) do
    Enum.each(messages, fn(%ScBot.Message{chat_id: chat_id, text: text, reply_to_message_id: reply_to_message_id}) ->
      HTTPoison.post(bot<>"/sendMessage", {:form, [chat_id: chat_id, text: text, parse_mode: "HTML", reply_to_message_id: reply_to_message_id]}, @post_headers)
    end)
  end
end
