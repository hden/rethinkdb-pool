'use strict'

Pool     = require "#{__dirname}/../"
{assert} = require 'chai'
co       = require 'co'

describe 'rethinkdb-pool', ->

  connection = undefined
  pool = undefined
  r = undefined

  before co -->
    pool = Pool {
      host: 'localhost'
      db: 'test'
    }

    {r} = pool

    yield pool.run r.tableCreate 'foo'

  after co -->
    yield pool.run r.tableDrop 'foo'

  beforeEach co -->
    connection = yield pool.acquire

  afterEach ->
    pool.release connection

  it 'should export rethinkdb client', ->
    assert.ok pool.r
    assert.ok pool.Promise

  it 'should acquire connection', co -->
    assert.ok connection

  it 'should run query', (done) ->
    query = r.dbList()
    pool.run query, (error, result) ->
      return done(error) if error?
      assert.include result, 'test'
      done()

  it 'should return a promise', co -->
    yield pool.run r.table('foo').insert [
      {foo: 'bar'}
      {baz: 'nyan'}
    ]

    list = yield pool.run r.table('foo')
    assert.propertyVal list, 'length', 2
