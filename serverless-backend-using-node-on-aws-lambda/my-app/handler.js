module.exports.run = (event, context, callback) => {
  console.log("I am a debug statement :)");
  callback(null, "Hello World");
}
