const CLBindings = require('../build/Release/bindings.node');

const CLBindingsErrorType = {
  CLocationErrorNoLocationService: 'CLocationErrorNoLocationService',
  CLocationErrorLocationServiceDenied: 'CLocationErrorLocationServiceDenied',
  CLocationErrorLocationUnknown: 'CLocationErrorLocationUnknown',
  CLocationErrorLookupFailed: 'CLocationErrorLookupFailed',
  CLocationErrorGeocodeCanceled: 'CLocationErrorGeocodeCanceled',
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
  {
    maximumAge = 120000,
    timeout = 0,
    enableHighAccuracy = true,
  } = {},
) {
  const options = {
    maximumAge,
    timeout,
    enableHighAccuracy,
  };
  const timestamp = new Date().getTime();

  try {
    const result = CLBindings.getCurrentPosition(options);

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

      case CLBindingsErrorType.CLocationErrorGeocodeCanceled:
        error = Object.assign(
          {},
          PositionErrorConsts,
          {
            code: HTML5PositionErrorType.TIMEOUT,
            message: 'Timeout',
          },
        );

        errorCallback && errorCallback(error);
        break;

      case CLBindingsErrorType.CLocationErrorNoLocationService:
      case CLBindingsErrorType.CLocationErrorLocationServiceDenied:
        error = Object.assign(
          {},
          PositionErrorConsts,
          {
            code: HTML5PositionErrorType.PERMISSION_DENIED,
            message: 'Permission denied',
          },
        );

        errorCallback && errorCallback(error);
        break;
    }
  }
}

exports.getCurrentPosition = getCurrentPosition;
