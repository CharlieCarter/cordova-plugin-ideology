var exec = require('cordova/exec');

var PLUGIN_NAME = "unbias"; // This is just for code completion uses.

var executeCallback = function(callback, message) {
  if (typeof callback === 'function') {
    callback(message);
  }
};

var Unbias = function() {}; // This just makes it easier for us to export all of the functions at once.
// All of your plugin functions go below this.
// Note: We are not passing any options in the [] block for this, so make sure you include the empty [] block.
Unbias.getArticles = function(onSuccess, onError) {
  exec(onSuccess, onError, PLUGIN_NAME, "getArticles", []);
};

Unbias.delJSON = function(onSuccess, onError) {
  exec(onSuccess, onError, PLUGIN_NAME, "delJSON", []);
};

Unbias.myName = function(onSuccess, onError) {
  exec(onSuccess, onError, PLUGIN_NAME, "myName", []);
};

Unbias.rewriteJsonWithArray = function(options, onSuccess, onError) {
  return new Promise(function(resolve, reject) {
    exec(function(message) {
      executeCallback(onSuccess, message);
      resolve(message);
    }, function(message) {
      executeCallback(onError, message);
      reject(message);
    }, PLUGIN_NAME, 'rewriteJsonWithArray', [options]);
  });
};

Unbias.getPersonEntities = function(options, onSuccess, onError) {
  return new Promise(function(resolve, reject) {
    exec(function(message) {
      executeCallback(onSuccess, message);
      resolve(message);
    }, function(message) {
      executeCallback(onError, message);
      reject(message);
    }, PLUGIN_NAME, 'getPersonEntities', [options]);
  });
}

module.exports = Unbias;
