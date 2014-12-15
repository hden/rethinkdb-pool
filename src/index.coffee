'use strict'

debug   = require('debug')('rethinkdb:pool')
{Pool}  = require 'generic-pool'
r       = require 'rethinkdb'
Promise = require 'bluebird'

module.exports = (options, max, min, idleTimeoutMillis, log) ->
  pool = Pool {
    name: 'rethinkdb'

    create: (done) ->
      r.connect options, done

    destroy: (connection) ->
      do connection.close

    log: log or debug
    max: max or 10
    min: min or 2
    idleTimeoutMillis: idleTimeoutMillis or 30000
  }

  acq     = Promise.promisify pool.acquire
  acquire = ->
    acq().disposer (connection) ->
      try
        pool.release connection
      catch e
        debug 'failed to release connection %s', e.message

  # exports rethinkdb driver
  pool.r = r
  pool.Promise = Promise

  # run helper
  pool.run = (query, done) ->
    debug 'querying'
    promise = Promise.using acquire(), (connection) ->
      debug 'acquired connection'
      query.run(connection).then (cursorOrResult) ->
        debug 'resolving'
        cursorOrResult?.toArray?() or cursorOrResult

    if done?
      promise.nodeify done
    else
      promise

  pool
