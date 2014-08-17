'use strict'

{Pool}  = require 'generic-pool'
r       = require 'rethinkdb'
debug   = require('debug')('rethinkdb:pool')
Promise = require "#{__dirname}/node_modules/rethinkdb/node_modules/bluebird"

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

  acquire = Promise.promisify pool.acquire

  # exports rethinkdb driver
  pool.r = r
  pool.Promise = Promise

  # run helper
  pool.run = (query, done) ->
    promise = acquire()
    .then(query.run.bind(query))
    .then (cursorOrResult) ->
      cursorOrResult.toArray?() or cursorOrResult

    if done?
      promise.nodeify done
    else
      promise

  pool
