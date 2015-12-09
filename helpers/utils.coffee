module.exports = {

	objectToArray: (obj) -> Object.keys(obj).map((v) -> obj[v]);

}