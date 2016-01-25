rethinkdb-pool
==============

[![Build Status](https://travis-ci.org/hden/rethinkdb-pool.svg?branch=master)](https://travis-ci.org/hden/rethinkdb-pool)
[![NPM version](https://badge.fury.io/js/rethinkdb-pool.svg)](http://badge.fury.io/js/rethinkdb-pool)

Connection-pool for RethinkDB

[![js-standard-style](https://cdn.rawgit.com/feross/standard/master/badge.svg)](https://github.com/feross/standard)

Installation
-----------

    npm install --save rethinkdb-pool

Usage
-----

## Create pool

```js
var r    = require('rethinkdb')
var Pool = require('rethinkdb-pool')
var pool = Pool(r, {
  host:'localhost',
  port:28015,
  db:'marvel',
  authKey:'hunter2'
})
```

## Run

```js
var query = r.table('foo').limit(100)

// callback
pool.run(query, function (error, list) {
  // no more acquire, no more toArray, yay!!
})

// promise
pool.run(query).then(function (list) {
  // promise, yay
})
```

## Acquire / release resources

```js
pool.acquire(function (error, connection) {
  if (error != null) {
    return handleError(error)
  }
  r.table('aTable').limit(10).run(connection, function (error, cursor) {
    if (error != null) {
      return handleError(error)
    }
    cursor.toArray(function (error, data) {
      if (error != null) {
        return handleError(error)
      }
      console.log(data)
      pool.release(connection)
    })
  })
})
```
