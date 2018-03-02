#import <CoreLocation/CoreLocation.h>

using namespace v8;
using namespace node;

@interface LocationManager : NSObject <CLLocationManagerDelegate> {
  CLLocationManager *_locationManager;

  bool _started;
  bool _hasLocation;
}

@property (readonly, getter=hasFailed) bool failed;
@property (readonly) NSInteger errorCode;

@property double maximumAge;
@property NSUInteger timeout;
@property bool enableHighAccuracy;

- (void)start;
- (void)stop;

- (CLLocation *)getCurrentLocation;

@end
