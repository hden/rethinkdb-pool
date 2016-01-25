/* global describe it before after */
'use strict'

const r = require('rethinkdb')
const assert = require('power-assert')
const createPool = require(__dirname + '/..')

function isArray (o) {
  var toString = {}.toString
  return toString.call(o) === '[object Array]'
}

describe('rethinkdb-pool', () => {
  var pool

  before(function () {
    this.timeout(5000)
    pool = createPool(r, { host: 'localhost', db: 'test' })
    return pool.run(r.tableCreate('foo')).then(function () {
      return pool.run(r.table('foo').insert([
        { foo: 'bar' },
        { baz: 'nyan' }
      ]))
    })
  })

  after(() => {
    return pool.run(r.tableDrop('foo'))
  })

  it('should acquire connection', (done) => {
    pool.acquire((e, conn) => {
      assert.ok(conn)
      pool.release(conn)
      done()
    })
  })

  it('should query', function () {
    return pool.run(r.table('foo')).then(function (result) {
      assert(isArray(result))
    })
  })

  it('should query with options', function () {
    return pool.run(r.table('foo'), { readMode: 'majority' }).then(function (result) {
      assert(isArray(result))
    })
  })

  it('should query with callback', function (done) {
    pool.run(r.table('foo'), function (e, result) {
      assert(result)
      assert(isArray(result))
      done()
    })
  })

  it('should query with options and callback', function (done) {
    pool.run(r.table('foo'), { readMode: 'majority' }, function (e, result) {
      assert(result)
      assert(isArray(result))
      done()
    })
  })

  it('should work with null', function () {
    return pool.run(r.table('foo').get('this_key_does_not_exist')).then(function (result) {
      assert(result === null)
    })
  })
})
