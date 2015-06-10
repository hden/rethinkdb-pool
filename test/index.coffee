'use strict'

Pool     = require "#{__dirname}/../"
r        = require 'rethinkdb'
{expect} = require 'chai'
co       = require 'co'

describe 'rethinkdb-pool', ->

  connection = undefined
  pool       = undefined

  before -> co ->
    pool = Pool {
      host: 'localhost'
      db: 'test'
      r: r
    }

    yield pool.run r.tableCreate 'foo'

  after -> co ->
    yield pool.run r.tableDrop 'foo'

  it 'should acquire connection', -> co ->
    connection = yield pool.acquire
    expect(connection).to.exist
    pool.release connection

  it 'should query', (done) ->
    query = r.tableList()
    pool.run query, (error, result) ->
      expect(result).to.be.an('array')
      done(error)

  it 'should query options', -> co ->
    query = r.tableList()
    pool.run(query, {}).then (result) ->
      expect(result).to.be.an('array')

  it 'should query cb', (done) ->
    query = r.tableList()
    pool.run query, (error, result) ->
      expect(result).to.be.an('array')
      done(error)

  it 'should query options cb', (done) ->
    query = r.tableList()
    pool.run query, {}, (error, result) ->
      expect(result).to.be.an('array')
      done(error)

  it 'should return a promise', -> co ->
    yield pool.run r.table('foo').insert [
      {foo: 'bar'}
      {baz: 'nyan'}
    ]

    promise = pool.run r.table('foo')
    expect(promise).to.respondTo 'then'

    result = yield promise
    expect(result).to.have.length.of(2)

  it 'should work with null', -> co ->
    result = yield pool.run r.table('foo').get 'this_key_does_not_exist'

    expect(result).to.be.null
