rethinkdb-pool
==============

Connection-pool for RethinkDB

Installation
-----------

    npm install --save rethinkdb-pool

Usage
-----

### Create pool

    var Pool = require('rethinkdb-pool');
    var pool = Pool({host:'localhost', port:28015, db:'marvel', authKey:'hunter2'});

### Exported helpers

    pool.r // rethinkdb-client
    pool.Promise // Bluebird Promise used by rethinkdb-client since v1.13.0

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

    var query = pool.r.table('foo').limit(100);

    // callback
    pool.run(query, function (error, list) {
      // no more acquire, no more toArray, yay!!
    });

    // promise
    pool.run(query).then(function (list) {
      // promise, yay
    });
