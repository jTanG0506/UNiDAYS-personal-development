module.exports.run = (event) => {
  return Promise.resolve("Hello");
}

// sls deploy
// sls deploy --function helloWorld
// sls invoke --function helloWorld
// sls invoke --function helloWorld --log
// sls logs --function helloWorld
