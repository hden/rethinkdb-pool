'use strict'

var createPool = require('generic-pool').createPool

function toArray (cursorOrResult) {
  if (cursorOrResult && typeof cursorOrResult.toArray === 'function') {
    return cursorOrResult.toArray()
  } else {
    return cursorOrResult
  }
}

module.exports = function (r, options) {
  var Promise = r._bluebird

  function create () {
    return r.connect(options).catch(function (e) {
      throw e
    })
  }

  function destroy (connection) {
    return connection.close().catch(function (e) {
      throw e
    })
  }

  function validate (connection) {
    return Promise.try(function () {
      return connection.isOpen()
    })
  }

  var factory = {
    create: create,
    destroy: destroy,
    validate: validate
  }

  var pool = createPool(factory, options)

  function acquire () {
    return Promise.resolve(pool.acquire()).disposer(function (conn) {
      return pool.release(conn)
    })
  }

  pool.run = function (query, opt, done) {
    if (typeof opt === 'function') {
      done = opt
      opt = null
    }

    var p = Promise.using(acquire(), function (conn) {
      return query.run(conn, opt)
    }).then(toArray)

    if (done) {
      p.then(function (d) {
        done(null, d)
      }).catch(done)
    } else {
      return p
    }
  }

  return pool
}
