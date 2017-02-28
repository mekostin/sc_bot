defmodule ScBot.Message do
  # {"ok":true,"result":[{"update_id":593164225,
  # "message":{"message_id":49,
  #               "from":{"id":349243463,"first_name":"Mikhail","last_name":"Kostin"},
  #               "chat":{"id":349243463,"first_name":"Mikhail","last_name":"Kostin","type":"private"},
  #           "date":1488122210,
  #           "text":"\u0440\u0440\u043e"}}]}

  defstruct chat_id: 0, text: "", reply_to_message_id: 0
end








#%{message: %{message_id: 49, chat: %{id: 349243463}, text: "asd"}}
