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
    return r.connect(options)
  }

  function destroy (connection) {
    return connection.close()
  }

  function validate (connection) {
    return new Promise(function (resolve, reject) {
      resolve(connection.isOpen())
    })
  }

  var factory = {
    create: create,
    destroy: destroy,
    validate: validate
  }

  var pool = createPool(factory, options)

  function acquire () {
    return new Promise(function (resolve, reject) {
      pool.acquire(function (e, conn) {
        e ? reject(e) : resolve(conn)
      })
    }).disposer(function (conn) { pool.release(conn) })
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
