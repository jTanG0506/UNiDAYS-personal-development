module.exports.run = async (event) => {
  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "Hello World"
    })
  }
}

// sls deploy
// sls deploy --function helloWorld
// sls invoke --function helloWorld
// sls invoke --function helloWorld --log
// sls logs --function helloWorld
