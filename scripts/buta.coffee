# Description:
#   Call buta.
#
# Notes:
#   buta.

cron = require('cron').CronJob

module.exports = (robot) ->

  new cron '0 0 */1 * * *', () =>
  # new cron '*/5 * * * * *', () =>
    robot.send {room: "#general"}, "「ぶた」「豚」「でぶ」などと発言すると会話がはじまります。豚BOTが#{+(EXPIRE_SEC / 60)}分間、あなたの発言に反応します。"
  , null, true, "Asia/Tokyo"

  # docomo
  EXPIRE_SEC=180
  DDS_API_KEY = '5a7961594e556774446f493247523043666c707467644452476b2f6e375957793239394c55493777726f39'
  DDS_DIALOGUE_URL = "https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue?APIKEY=#{DDS_API_KEY}"

  request = require 'request'
  redis = require('redis')
  client = redis.createClient(process.env.REDISCLOUD_URL, {no_ready_check: true})

  Array::compact = ->
    (elem for elem in this when elem?)
  Array::first ?= (n) ->
    if n? then @[0...(Math.max 0, n)] else @[0]
  Array::last ?= (n) ->
    if n? then @[(Math.max @length - n, 0)...] else @[@length - 1]

  robot.hear /(ばいばい|バイバイ|おやすみ|オヤスミ)/, (msg) ->
    # dialog session finish
    key = make_dialog_session_key msg
    client.del(key)

  robot.hear /(ぶた|ブタ|豚|でぶ|デブ|buta)/, (msg) ->
    # dialog session start
    key = make_dialog_session_key msg
    client.set(key, true, 'EX', EXPIRE_SEC)
    # res
    word = msg.match[1]
    msg.send "今#{word}って言ったかこの野郎"

  robot.hear /(もこ|モコ)/, (msg) ->
    msg.send "もこもこ"

  robot.hear /.*/, (msg) ->
    key = make_dialog_session_key msg
    client.get key, (err, reply) ->
      # console.log "hasDs=#{reply}"
      if reply
        send_dialog msg

  make_dialog_session_key = (msg) ->
    "d_s_#{msg.envelope.user.id}"

  send_dialog = (msg) ->
    userId = msg.envelope.user.id
    text = msg.message.text
    contextKey = "dds_ctx_#{userId}"
    savedContextValue = client.get contextKey
    savedContextValue = "" if savedContextValue?.length? <= 0

    data = JSON.stringify(
      utt: text
      nickname: msg.envelope.user.name
      context: savedContextValue
      mode: "dialog"
    )

    robot.http(DDS_DIALOGUE_URL)
      .header('Content-Type', 'application/json')
      .post(data) (err, response, body) ->
        if err
          return
        json = JSON.parse body
        msg.send json.utt
        client.set(contextKey, json.context, 'EX', EXPIRE_SEC)
        
    # data = {
    #   utt: "こんにちは",
    #   context: "",
    #   # nickname: "光",
    #   # nickname_y: "ヒカリ",
    #   # sex: "女",
    #   # bloodtype: "B",
    #   # birthdateY: "1997",
    #   # birthdateM: "5",
    #   # birthdateD: "30",
    #   # age: "16",
    #   # constellations: "双子座",
    #   # place: "東京",
    #   mode: "dialog"
    # }

    # {
    #   "utt": "ちわー",
    #   "yomi": "ちわー",
    #   "mode": "dialog",
    #   "da": "0",
    #   "context": "zdAU-C2RSLSabNMizCuA1Q"
    # }


  robot.hear /(修造|しゅうぞう|shuzo|shuuzo)/, (msg) ->
    msgs = [
        '何を言われてもイライラしなーい'
        '予想外の人生になっても、そのとき、幸せだったらいいんじゃないかな'
        '真剣だからこそ、ぶつかる壁がある'
        'お醤油ベースのお吸い物にあんこ。非常識の中に常識あり'
        '苦しいか？ 修造！笑え！'
        '真剣に考えても、深刻になるな！'
        '崖っぷちありがとう！最高だ！'
        'そうだ、僕は、心から本当にテニスが大好きなんだ！'
        'いま　ここ　修造'
        '自分を好きになれ！'
        '反省はしろ！後悔はするな！'
    ]
    msg.send msg.random msgs

  # robot.hear /.*/, (msg) ->
  #   kuromoji = require("kuromoji")
  #   options = {
  #     dicPath: "node_modules/kuromoji/dist/dic"
  #   }
  #   kuromoji.builder(options)
  #     .build (err, tokenizer) ->
  #       # console.log msg.message.tokenized
  #       tokens = msg.message.tokenized
  #       outs = [
  #         subtoken(tokens, ['形容詞'])
  #         subtoken(tokens, ['助動詞','動詞'])
  #       ]
  #       outs = (out for out in outs when out.length > 0)
  #       out = msg.random outs
  #       if out?
  #         msg.send "#{msg.random outs}フレンズなんだね！"

  # subtoken = (tokens, hitPosTypes) ->
  #   outs = []
  #   for i, token of tokens
  #     outs.push token.surface_form
  #     # console.log token, outs
  #     if token.pos in hitPosTypes
  #       return outs.compact().join('')
  #   []

#MEMO
# buta> Response {
#   robot:
#    Robot {
#      adapterPath: '/Users/rogata/Documents/workspace/heroku/himechan/node_modules/hubot/src/adapters',
#      name: 'buta',
#      events:
#       EventEmitter {
#         domain: null,
#         _events: [Object],
#         _eventsCount: 2,
#         _maxListeners: undefined },
#      brain: Brain { data: [Object], autoSave: true, saveInterval: [Object] },
#      alias: false,
#      adapter: Shell { robot: [Circular], _events: {}, _eventsCount: 0, cli: [Object] },
#      Response: [Function: Response],
#      commands:
#       [ 'hubot help - Displays all of the help commands that Hubot knows about.',
#         'hubot help <query> - Displays all help commands that match <query>.' ],
#      listeners:
#       [ [Object],
#         [Object],
#         [Object],
#         [Object],
#         [Object],
#         [Object],
#         [Object],
#         [Object],
#         [Object],
#         [Object] ],
#      middleware: { listener: [Object], response: [Object], receive: [Object] },
#      logger: EventEmitter { level: 6, stream: [Object] },
#      pingIntervalId: null,
#      globalHttpOptions: {},
#      version: '2.19.0',
#      server:
#       Server {
#         domain: null,
#         _events: [Object],
#         _eventsCount: 2,
#         _maxListeners: undefined,
#         _connections: 0,
#         _handle: [Object],
#         _usingSlaves: false,
#         _slaves: [],
#         _unref: false,
#         allowHalfOpen: true,
#         pauseOnConnect: false,
#         httpAllowHalfOpen: false,
#         timeout: 120000,
#         _pendingResponseData: 0,
#         _connectionKey: '4:0.0.0.0:8080' },
#      router:
#       { [Function: app]
#         use: [Function],
#         handle: [Function],
#         listen: [Function],
#         domain: undefined,
#         _events: [Object],
#         _maxListeners: undefined,
#         setMaxListeners: [Function: setMaxListeners],
#         getMaxListeners: [Function: getMaxListeners],
#         emit: [Function: emit],
#         addListener: [Function: addListener],
#         on: [Function: addListener],
#         prependListener: [Function: prependListener],
#         once: [Function: once],
#         prependOnceListener: [Function: prependOnceListener],
#         removeListener: [Function: removeListener],
#         removeAllListeners: [Function: removeAllListeners],
#         listeners: [Function: listeners],
#         listenerCount: [Function: listenerCount],
#         eventNames: [Function: eventNames],
#         route: '/',
#         stack: [Object],
#         init: [Function],
#         defaultConfiguration: [Function],
#         engine: [Function],
#         param: [Function],
#         set: [Function],
#         path: [Function],
#         enabled: [Function],
#         disabled: [Function],
#         enable: [Function],
#         disable: [Function],
#         configure: [Function],
#         acl: [Function],
#         bind: [Function],
#         checkout: [Function],
#         connect: [Function],
#         copy: [Function],
#         delete: [Function],
#         get: [Function],
#         head: [Function],
#         link: [Function],
#         lock: [Function],
#         'm-search': [Function],
#         merge: [Function],
#         mkactivity: [Function],
#         mkcalendar: [Function],
#         mkcol: [Function],
#         move: [Function],
#         notify: [Function],
#         options: [Function],
#         patch: [Function],
#         post: [Function],
#         propfind: [Function],
#         proppatch: [Function],
#         purge: [Function],
#         put: [Function],
#         rebind: [Function],
#         report: [Function],
#         search: [Function],
#         subscribe: [Function],
#         trace: [Function],
#         unbind: [Function],
#         unlink: [Function],
#         unlock: [Function],
#         unsubscribe: [Function],
#         all: [Function],
#         del: [Function],
#         render: [Function],
#         request: [Object],
#         response: [Object],
#         cache: {},
#         settings: [Object],
#         engines: {},
#         _eventsCount: 1,
#         _router: [Object],
#         routes: [Object],
#         router: [Getter],
#         locals: [Object],
#         _usedRouter: true },
#      adapterName: 'shell',
#      errorHandlers: [],
#      onUncaughtException: [Function] },
#   message:
#    TextMessage {
#      user: User { id: '1', name: 'Shell', room: 'Shell' },
#      text: '1?',
#      id: 'messageId',
#      done: false,
#      room: 'Shell',
#      tokenized: [ [Object], [Object] ] },
#   match: [ '1?', '1', index: 0, input: '1?' ],
#   envelope:
#    { room: 'Shell',
#      user: User { id: '1', name: 'Shell', room: 'Shell' },
#      message:
#       TextMessage {
#         user: [Object],
#         text: '1?',
#         id: 'messageId',
#         done: false,
#         room: 'Shell',
#         tokenized: [Object] } } }
