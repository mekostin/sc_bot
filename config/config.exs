use Mix.Config

config :sc_bot,
  chat_password: System.get_env("CHAT_PASSWORD"),
  bot_token: System.get_env("BOT_TOKEN"),
  db_username: System.get_env("DB_USERNAME"),
  db_password: System.get_env("DB_PASSWORD"),
  db_hostname: System.get_env("DB_HOSTNAME"),
  info_database: "accounting",
  status_database: "zabbix",

  forum_username: System.get_env("FORUM_USERNAME"),
  forum_password: System.get_env("FORUM_PASSWORD"),
  forum_hostname: System.get_env("FORUM_HOSTNAME"),
  forum_database: System.get_env("FORUM_DATABASE"),
  forum_chat_id:  System.get_env("FORUM_CHAT_ID"),

  # CONCAT(b.name, '(', b.id_board, ')/'),
  # CONCAT(m.subject, '(', m.id_topic, ')/' ),
  # CONCAT(m.body, '(', m.id_msg, ')' )

  forum_mess_id_sql: "select max(id_msg) as data FROM smf_messages",
  forum_messages_sql: "
SELECT
CONCAT(b.name, '
  ', m.subject, '
    ', m.body) as data,
    id_msg
    FROM smf_messages m
    LEFT JOIN smf_boards b ON b.id_board = m.id_board
    where m.id_board<>3 and m.id_msg>",

#COMMANDS
  item_regex: "^(ATM|atm|trouter)_\\d{2,5}$",

  help_command: "
<b>help</b> - show this help
<b>info atm_#</b> - show information from DB (node, contacts, address)
<b>info trouter_#</b> - show information from DB (node, contacts, address)
<b>status atm_#</b> - show current connection status of ATM
<b>status trouter_#</b> - show current connection status of trouter

forum broadcasting invite link "<> System.get_env("PRIVATE_CHANNEL")
