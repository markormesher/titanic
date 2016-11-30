rfr = require('rfr')
guid = require('guid')
mysql = rfr('./helpers/mysql')
auth = rfr('./helpers/auth')
module.exports = {

  # Return the user with the given email
	get: (email, callback) ->
    query = "SELECT * FROM USERS WHERE email = ?";
    connection = mysql.getConnection((conn) ->
				q = mysql.makeSelectQuery('User', { email: email })

				queryString = q[0]
				values = q[1]
	      conn.query(queryString, values, (err, results) ->
	        if (err) then return callback(err)
	        user = null;
	        if (results.length > 0)
	          user = results[0]
	          return user;
	      )
		);

  createUser: (email, password) ->
    connection = mysql.getConnection((conn) ->
				q = mysql.makeInsertQuery('User', {
						id: guid.create().value
						email: email,
						password: auth.sha256(password)
				})
				query = q[0]
				inserts = q[1]
	      conn.query(query, inserts, (err, results) ->
	        if (err) then return callback(err)
	        console.log(results);
	      )
    );
}
