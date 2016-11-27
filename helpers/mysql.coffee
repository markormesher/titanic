mysql = require('mysql')
rfr = require('rfr')
secrets = rfr('./secrets.json')

module.exports = {

	getConnection: (onComplete) ->
		connection = mysql.createConnection(secrets.MYSQL_CONFIG)
		connection.connect((err) ->
			if (err)
				throw err
			onComplete(connection)
		)

	makeSelectQuery: (table, where) ->
		queryStr = "SELECT * FROM #{table} WHERE 1"
		queryValues = []
		if (query != {})
			for k, v of where
				queryStr += " AND #{k} = ?"
				queryValues.push(v)
		queryStr += ";"
		return [queryStr, queryValues]

	makeInsertQuery: (table, fields) ->
		queryStr = "INSERT INTO #{table}("
		queryValues = []
		for k, v of fields
			queryStr += "#{k}, "
			queryValues.push(v)
		queryStr = queryStr.substr(0, queryStr.length - 2)
		queryStr += ") VALUES ("
		for k, v of fields
			queryStr += "?, "
		queryStr = queryStr.substr(0, queryStr.length - 2)
		queryStr += ");"
		return [queryStr, queryValues]

	makeUpdateQuery: (table, fields, where) ->
		queryStr = "UPDATE #{table} SET"
		queryValues = []
		for k, v of fields
			queryStr += " #{k} = ?,"
			queryValues.push(v)
		queryStr = queryStr.substr(0, queryStr.length - 1)
		queryStr += " WHERE 1"
		for k, v of where
			queryStr += " AND #{k} = ?"
			queryValues.push(v)
		return [queryStr, queryValues]

}
