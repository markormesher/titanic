// dependencies
var fs = require('fs');
var g = require('gulp');
var gUtils = require('gulp-util');
var GulpSSH = require('gulp-ssh');

// set up SSH
var gSsh = new GulpSSH({
	sshConfig: {
		host: 'devon',
		port: 22,
		username: 'deploy',
		privateKey: fs.readFileSync('/home/markormesher/.ssh/id_rsa')
	}
});

g.task('default', function () {
	return gUtils.log('Gulp is running!');
});

g.task('update-live', function () {
	return gSsh.shell([
		'cd /var/node/titanic.markormesher.co.uk',
		'pm2 stop titanic',
		'git pull',
		'npm install',
		'pm2 start titanic.js'
	]);
});
