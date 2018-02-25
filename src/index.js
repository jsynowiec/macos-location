const CLBindings = require('../build/Release/bindings.node');

const CLBindingsErrorType = {
  CLocationErrorNoLocationService: 'CLocationErrorNoLocationService',
  CLocationErrorLocationServiceDenied: 'CLocationErrorLocationServiceDenied',
  CLocationErrorLocationUnknown: 'CLocationErrorLocationUnknown',
  CLocationErrorLookupFailed: 'CLocationErrorLookupFailed',
};

const HTML5PositionErrorType = {
  PERMISSION_DENIED: 1,
  POSITION_UNAVAILABLE: 2,
  TIMEOUT: 3,
};

const PositionErrorConsts = {
  PERMISSION_DENIED: HTML5PositionErrorType.PERMISSION_DENIED,
  POSITION_UNAVAILABLE: HTML5PositionErrorType.POSITION_UNAVAILABLE,
  TIMEOUT: HTML5PositionErrorType.TIMEOUT,
};

let lastResult;

function getCurrentPosition(
  successCallback,
  errorCallback,
  options = {
    maximumAge: 0,
    timeout: 0, // dummy, value is not used
    enableHighAccuracy: false, // dummy, value is not used
  },
) {
  const timestamp = new Date().getTime();

  if (
    options.maximumAge &&
    options.maximumAge > 0 &&
    lastResult &&
    lastResult.timestamp + options.maximumAge >= timestamp
  ) {
    successCallback(lastResult);
  } else {
    try {
      const result = CLBindings.getCurrentPosition();

      lastResult = {
        coords: {
          accuracy: result.horizontalAccuracy,
          altitude: result.altitude,
          altitudeAccuracy: result.verticalAccuracy,
          heading: null,
          latitude: result.latitude,
          longitude: result.longitude,
          speed: null,
        },
        timestamp: result.timestamp,
      };

      successCallback(lastResult);
    } catch (e) {
      let error;

      switch (e.message) {
        case CLBindingsErrorType.CLocationErrorLookupFailed:
        case CLBindingsErrorType.CLocationErrorLocationUnknown:
          error = Object.assign(
            {},
            PositionErrorConsts,
            {
              code: HTML5PositionErrorType.POSITION_UNAVAILABLE,
              message: 'Position unavailable',
            },
          );

          errorCallback && errorCallback(error);
          break;

        case CLBindingsErrorType.CLocationErrorNoLocationService:
        case CLBindingsErrorType.CLocationErrorLocationServiceDenied:
          error = {
            ...PositionErrorConsts,
            code: HTML5PositionErrorType.PERMISSION_DENIED,
            message: 'Permission denied',
          };

          errorCallback && errorCallback(error);
          break;
      }
    }
  }
}

exports.getCurrentPosition = getCurrentPosition;
