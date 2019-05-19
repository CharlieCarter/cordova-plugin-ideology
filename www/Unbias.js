var exec = require('cordova/exec');

var PLUGIN_NAME = "unbias"; // This is just for code completion uses.

var Unbias = function() {}; // This just makes it easier for us to export all of the functions at once.
// All of your plugin functions go below this.
// Note: We are not passing any options in the [] block for this, so make sure you include the empty [] block.
Unbias.getArticles = function(onSuccess, onError) {
   exec(onSuccess, onError, PLUGIN_NAME, "getArticles", []);
};
Unbias.delJSON = function(onSuccess, onError) {
   exec(onSuccess, onError, PLUGIN_NAME, "delJSON", []);
};
module.exports = Unbias;
