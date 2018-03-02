#include <math.h>
#include <node.h>
#include <v8.h>

#import "LocationManager.h"

@implementation LocationManager

- (id)init {
  if (self = [super init]) {
    _locationManager = nil;
    _hasLocation = NO;
    _started = NO;
    _failed = NO;

    self.maximumAge = 120.0; // two minutes
    self.enableHighAccuracy = NO; // no, use best
    self.timeout = 0; // won't return until the position is available
  }

  return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
  CLLocation* location = [locations lastObject];
  NSTimeInterval locationAge = [NSDate.date timeIntervalSinceDate:location.timestamp];

  if (locationAge >= self.maximumAge) {
    return;
  }

  // negative horizontal accuracy means no location fix
  if (location.horizontalAccuracy < 0.0) {
    return;
  }

  _hasLocation = YES;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
  // Don't care about heading so continue
  if (error.code == kCLErrorHeadingFailure) {
    return;
  }

  _failed = YES;
  _errorCode = error.code;
}

- (void)start {
  if (_started) {
    return;
  }

  _hasLocation = NO;

  if (!_locationManager) {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
  }

  double desiredAccuracy = (self.enableHighAccuracy) ? kCLLocationAccuracyBestForNavigation : kCLLocationAccuracyHundredMeters;
  [_locationManager setDesiredAccuracy:desiredAccuracy];

  [_locationManager performSelectorOnMainThread:@selector(startUpdatingLocation) withObject:nil waitUntilDone:YES];

  _started = YES;
}

- (void)stop {
  if (!_started) {
    return;
  }

  [_locationManager performSelectorOnMainThread:@selector(stopUpdatingLocation) withObject:nil waitUntilDone:YES];
  _started = NO;
}

- (CLLocation *)getCurrentLocation {
  [self start];

  NSDate* end = (self.timeout > 0) ? [NSDate dateWithTimeIntervalSinceNow:(NSUInteger)ceil(self.timeout / 1000)] : nil;

  while (!(self.timeout == 0) || [(NSDate *)NSDate.date compare:end] != NSOrderedDescending) {
    if (_hasLocation) {
      [self stop];

      return _locationManager.location;
    }

    if ([self hasFailed]) {
      return nil;
    }

    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
  }

  // Timeout
  _failed = YES;
  _errorCode = kCLErrorGeocodeCanceled;

  return nil;
}

-(void)dealloc
{
    [_locationManager release];
    [super dealloc];
}

@end
