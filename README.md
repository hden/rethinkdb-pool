rethinkdb-pool
==============

[![Build Status](https://travis-ci.org/hden/rethinkdb-pool.svg?branch=master)](https://travis-ci.org/hden/rethinkdb-pool)
[![NPM version](https://badge.fury.io/js/rethinkdb-pool.svg)](http://badge.fury.io/js/rethinkdb-pool)

Connection-pool for RethinkDB

Installation
-----------

    npm install --save rethinkdb-pool

Usage
-----

### Create pool

    // run node with --harmony to use built-in Promise
    // or require any compatible library of your choise
    var r    = require('rethinkdb')
    var Pool = require('rethinkdb-pool');
    var pool = Pool({
      host:'localhost',
      port:28015,
      db:'marvel',
      authKey:'hunter2',
      r: r,
      Promise: Promise
    });

### Acquire / release resources

    pool.acquire(function (error, connection) {
      if (error != null) {
        return handleError(error);
      }
      r.table('aTable').limit(10).run(connection, function (error, cursor) {
        if (error != null) {
          return handleError(error);
        }
        cursor.toArray(function (error, data) {
          if (error != null) {
            return handleError(error);
          }
          console.log(data);
          pool.release(connection);
        });
      });
    });

### Run

    var query = r.table('foo').limit(100);

    // callback
    pool.run(query, function (error, list) {
      // no more acquire, no more toArray, yay!!
    });

    // promise
    pool.run(query).then(function (list) {
      // promise, yay
    });
