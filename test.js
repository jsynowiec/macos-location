const { getCurrentPosition } = require('./src/index');

function successCallback(position) {
  console.log('Your current position is:');
  console.log(`Latitude : ${position.coords.latitude}`);
  console.log(`Longitude: ${position.coords.longitude}`);
  console.log(`More or less ${position.coords.accuracy} meters.`);
};

function errorCallback(err) {
  console.warn(`ERROR(${err.code}): ${err.message}`);
};

getCurrentPosition(successCallback, errorCallback, {
  maximumAge: 120000,
  enableHighAccuracy: true,
});
