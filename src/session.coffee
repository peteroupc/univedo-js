Ws = if WebSocket? then WebSocket else require 'ws'

univedo.Session = class Session
  constructor: (url, opts, @onopen = (->), @onclose = (->), @onerror = (->)) ->
    @_socket = new Ws(url)
    @_socket.onopen = =>
      @_urologin = new univedo.RemoteObject(this, 0, ['getSession'])
      @_urologin.getSession opts, (conn) =>
        @_connection = conn
        @onopen(this)
    @_socket.onmessage = @_onmessage
    @_socket.onerror = @_onerror
    @_socket.onclose = @_onclose
    @_remote_objects = {}

  close: ->
    @_socket.close()

  ping: (v, onreturn) ->
    @_connection.ping(v, onreturn)

  getPerspective: (uuid, onreturn) ->
    @_connection.getPerspective(uuid, onreturn)

  _onclose: (e) =>
    @onclose()

  _onmessage: (e) =>
    # This is unneccessary in the browser. However node's ws returns a Buffer
    # instead of an ArrayBuffer, which is normalized to an ArrayBuffer here.
    msg = new univedo.Message(new Uint8Array(e.data).buffer, @_receiveRo)
    @_remote_objects[msg.shift()]._receive(msg)

  _receiveRo: (arr) =>
    [id, name] = arr
    klass = univedo.remote_classes[name]
    throw Error "unknown remote object class " + name unless klass
    ro = new klass(this, id)

  _onerror: (e) =>
    console.error "error " + e
    @onerror()

  _sendMessage: (m) ->
    msg = new univedo.Message()
    msg.send v for v in m
    @_socket.send(msg.sendBuffer)
