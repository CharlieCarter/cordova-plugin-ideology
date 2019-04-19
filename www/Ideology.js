var exec = require('cordova/exec');

var PLUGIN_NAME = "Ideology"; // This is just for code completion uses.

var Ideology = function() {}; // This just makes it easier for us to export all of the functions at once.
// All of your plugin functions go below this.
// Note: We are not passing any options in the [] block for this, so make sure you include the empty [] block.
Ideology.test = function(onSuccess, onError) {
   exec(onSuccess, onError, PLUGIN_NAME, "test", []);
};
module.exports = Ideology;
