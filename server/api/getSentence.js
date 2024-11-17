const axios = require('axios');

const getSentence = async() => {
  const jokeData = await  axios.get("http://api.quotable.io/random");
  return jokeData.data.content.split(" ");

};

module.exports = getSentence;