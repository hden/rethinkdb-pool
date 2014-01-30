'use strict'

{Pool} = require 'generic-pool'
r      = require 'rethinkdb'
debug  = require('debug')('rethinkdb:pool')

module.exports = (options, max, min, idleTimeoutMillis) ->
  Pool {
    name: 'rethinkdb'

    create: (done) ->
      r.connect options, done

    destroy: (connection) ->
      do connection.close

    log: debug
    max: max or 10
    min: min or 2
    idleTimeoutMillis: idleTimeoutMillis or 30000
  }
