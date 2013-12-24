univedo = require('../lib/univedo.js')

String.prototype.b = ->
  buf = new ArrayBuffer(@length)
  bufView = new Uint8Array(buf)
  for i in [0..@length-1]
    bufView[i] = @charCodeAt(i)
  buf

setUp: (done) ->
  done()

exports['cbor'] =

  readsSimple: (t) ->
    t.equal new univedo.Message("\xf6".b()).read(), null, 'reads null'
    t.equal new univedo.Message("\xf5".b()).read(), true, 'reads true'
    t.equal new univedo.Message("\xf4".b()).read(), false, 'reads false'
    t.done()

  readsIntegers: (t) ->
    t.equal new univedo.Message("\x18\x2a".b()).read(), 42, 'reads uint'
    t.equal new univedo.Message("\x18\x64".b()).read(), 100, 'reads uint'
    t.equal new univedo.Message("\x1a\x00\x0f\x42\x40".b()).read(), 1000000, 'reads uint'
    t.equal new univedo.Message("\x20".b()).read(), -1, 'reads nint'
    t.equal new univedo.Message("\x38\x63".b()).read(), -100, 'reads nint'
    t.equal new univedo.Message("\x39\x03\xe7".b()).read(), -1000, 'reads nint'
    t.done()

  readsFloats: (t) ->
    t.equal new univedo.Message("\xfa\x47\xc3\x50\x00".b()).read(), 100000.0, 'reads floats'
    t.equal new univedo.Message("\xfb\x3f\xf1\x99\x99\x99\x99\x99\x9a".b()).read(), 1.1, 'reads floats'
    t.done()

  readsStrings: (t) ->
    t.deepEqual new univedo.Message("\x46foobar".b()).read(), "foobar".b(), 'reads blobs'
    t.equal new univedo.Message("\x66foobar".b()).read(), "foobar", 'reads strings'
    # t.deepEqual new univedo.Message("\x66f\xc3\xb6obar".b()).read(), "föobar", 'reads strings'
    t.done()

  readsCollections: (t) ->
    t.deepEqual new univedo.Message("\x82\x63foo\x63bar".b()).read(), ["foo", "bar"], 'reads arrays'
    t.deepEqual new univedo.Message("\xa2\x63bar\x02\x63foo\x01".b()).read(), {foo: 1, bar: 2}, 'reads maps'
    t.done()

  readsTimes: (t) ->
    # t.deepEqual new univedo.Message("\xc9\x1b\x00\x04\xDA\x8B\x0D\xFF\x7F\x40".b()).read(), new Date(1366190677), 'reads datetimes'
    # t.deepEqual new univedo.Message("\xc8\x1b\x00\x04\xDA\x8B\x0D\xFF\x7F\x40".b()).read(), 1366190677, 'reads times'
    t.done()

  readsUuids: (t) ->
    t.equal new univedo.Message("\xc7\x50\x68\x4E\xF8\x95\x72\xA2\x42\x98\xBC\x5B\x58\x0F\x1C\x1D\x27\x07".b()).read(), "684ef895-72a2-4298-bc5b-580f1c1d2707", 'reads uuids'
    t.done()

  sendsSimple: (t) ->
    t.deepEqual new univedo.Message().sendImpl(null), "\xf6".b(), 'sends null'
    t.deepEqual new univedo.Message().sendImpl(true), "\xf5".b(), 'sends true'
    t.deepEqual new univedo.Message().sendImpl(false), "\xf4".b(), 'sends false'
    t.done()

  sendsIntegers: (t) ->
    t.deepEqual new univedo.Message().sendImpl(1), "\x01".b(), 'sends uint'
    t.deepEqual new univedo.Message().sendImpl(42), "\x18\x2a".b(), 'sends uint'
    t.deepEqual new univedo.Message().sendImpl(100), "\x18\x64".b(), 'sends uint'
    t.deepEqual new univedo.Message().sendImpl(1000000), "\x1a\x00\x0f\x42\x40".b(), 'sends uint'
    t.deepEqual new univedo.Message().sendImpl(-1), "\x20".b(), 'sends nint'
    t.deepEqual new univedo.Message().sendImpl(-100), "\x38\x63".b(), 'sends nint'
    t.deepEqual new univedo.Message().sendImpl(-1000), "\x39\x03\xe7".b(), 'sends nint'
    t.done()