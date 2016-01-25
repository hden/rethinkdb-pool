'use strict'

debug   = require('debug')('rethinkdb:pool')
{Pool}  = require 'generic-pool'

isFunction = (f) ->
  typeof f is 'function'

module.exports = (options = {}) ->
  opts = {}

  for k, v of options when k not in ['max', 'min', 'idleTimeoutMillis', 'log']
    opts[k] = v

  pool = Pool {
    name: 'rethinkdb'

    create: (done) ->
      options.r.connect opts, done

    destroy: (connection) ->
      do connection.close

    log: options.log or debug
    max: options.max or 10
    min: options.min or 2
    idleTimeoutMillis: options.idleTimeoutMillis or 30 * 1000
  }

  pool.r = options.r

  # run helper
  run = pool.pooled (connection, query, args..., done) ->
    debug 'querying'
    args.unshift(connection)
    args.push(done)
    query.run.apply(query, args)

  Promise  = options.Promise or global.Promise
  pool.run = (query, opt, done) ->
    args = [query]

    if isFunction(opt)
      done = opt
      opt  = null

    if opt?
      args.push(opt)

    promise = new Promise (resolve, reject) ->
      args.push (error, cursorOrResult) ->
        debug 'resolving'
        if error?
          reject(error)
        else
          resolve(cursorOrResult?.toArray?() or cursorOrResult)

      run.apply(pool, args)

    if done?
      promise.then((d) -> done(null, d)).catch(done)
    else
      promise

  pool
