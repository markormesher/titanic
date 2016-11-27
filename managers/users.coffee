rfr = require('rfr')
guid = require('guid')
mysql = rfr('helpers/mysql')
Device = rfr('./models/device')

module.exports = {

  # Return the user with the given email
	get: (email, callback) ->
    query = "SELECT * FROM USERS WHERE email = ?";
    connection = mysql.getConnection((conn) ->
      conn.query(query, [email], (err, results) ->
        if (err) then return callback(err)
        user = null;
        if (results.length > 0)
          user = results[0]
          return user;
      )
    );

  createUser: (email, password) ->
    connection = mysql.getConnection((conn) ->
      query = "INSERT INTO User(id, email, password) VALUES(?, ?, ?)"
      inserts = [guid.create().value, email, password]
      conn.query(query, inserts, (err, results) ->
        if (err) then return callback(err)
        console.log(results);
      )
    );
}
