# macos-location [![Latest version on NPM registy][badge-npm-version]][package-npm]

[![Node.js version][nodejs-badge]][nodejs]
[![License][badge-license]][license]

[![Donate][badge-donate]][donate]

Wrapper around macOS [Core Location][corelocation] services. Can serve as a drop-in replacement for [HTML5 Geolocation API][w3-geolocation-api] in Electron applications.

**Note:** This module is intended for Electron applications targeted at macOS.

## Installation

```
npm install macos-location --save
```

or

```
yarn add macos-location
```

## Usage

This module exports a single `getCurrentPosition` method that has exactly the same signature as [`navigator.geolocation.getCurrentPosition`][w3-geolocation-api-getcurrentpos].

If you were using HTML5 Geolocation API to retrieve user's location you can simply replace calls to navigator's `getCurrentPosition` method with this module.

```js
const { getCurrentPosition } = require('macos-location');

function successCallback(position) {
  console.log('Your current position is:');
  console.log(`Latitude : ${position.coords.latitude}`);
  console.log(`Longitude: ${position.coords.longitude}`);
  console.log(`More or less ${position.coords.accuracy} meters.`);
};

function errorCallback(err) {
  console.warn(`ERROR(${err.code}): ${err.message}`);
};

// https://developer.mozilla.org/en-US/docs/Web/API/PositionOptions
const options = {
  maximumAge: 60000,
};

getCurrentPosition(successCallback, errorCallback, options);
```

If you don't like callbacks, you can wrap the location request in a Promise.

```js
const { getCurrentPosition } = require('macos-location');

const p = new Promise((resolve, reject) => {
  getCurrentPosition(resolve, reject);
});
```

## License

Released under the the [MIT License][license].

[corelocation]: https://developer.apple.com/documentation/corelocation
[w3-geolocation-api]: https://www.w3.org/TR/geolocation-API/
[w3-geolocation-api-position-options]: https://www.w3.org/TR/geolocation-API/#position_options_interface
[w3-geolocation-api-getcurrentpos]: https://w3c.github.io/geolocation-api/#dom-geolocation-getcurrentposition
[license]: https://raw.githubusercontent.com/jsynowiec/osx-location/master/LICENSE

[nodejs-badge]: https://img.shields.io/badge/node->=%206.9-blue.svg
[nodejs]: https://nodejs.org/dist/latest-v6.x/docs/api/s
[badge-npm-version]: https://img.shields.io/npm/v/macos-location.svg
[package-npm]: https://www.npmjs.com/package/macos-location
[badge-license]: https://img.shields.io/github/license/jsynowiec/macos-location.svg
[badge-donate]: https://img.shields.io/badge/☕-buy%20me%20a%20coffee-46b798.svg
[donate]: https://paypal.me/jaqb/5eur
