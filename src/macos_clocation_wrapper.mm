#include <math.h>
#include <node.h>
#include <v8.h>

#import <CoreLocation/CoreLocation.h>

using namespace v8;
using namespace node;

@interface LocationManagerDelegate : NSObject <CLLocationManagerDelegate> {}

@property double latitude;
@property double longitude;
@property double altitude;
@property double horizontalAccuracy;
@property double verticalAccuracy;
@property NSInteger timestamp;

@property (getter=hasFailed) bool failed;
@property NSInteger errorCode;

@property double maximumAge;
@property bool enableHighAccuracy;

- (void)locationManager:(CLLocationManager *)manager
  didUpdateLocations:(NSArray<CLLocation *> *)locations;

- (void)locationManager:(CLLocationManager *)manager
  didFailWithError:(NSError *)error;

@end

@implementation LocationManagerDelegate

-(id)init {
  if (self = [super init]) {
    self.failed = NO;
    self.maximumAge = 0.1;
    self.enableHighAccuracy = NO;
  }
  return self;
}

- (void)locationManager:(CLLocationManager *)manager
  didUpdateLocations:(NSArray<CLLocation *> *)locations {
  @autoreleasepool {
    // In case there were several requests the last object is the most recent one
    CLLocation *location = [locations lastObject];
    NSTimeInterval locationAge = [location.timestamp timeIntervalSinceNow];

    if (abs(locationAge) < self.maximumAge) {
      self.latitude = location.coordinate.latitude;
      self.longitude = location.coordinate.longitude;
      self.altitude = location.altitude;
      self.horizontalAccuracy = location.horizontalAccuracy;
      self.verticalAccuracy = location.verticalAccuracy;

      NSTimeInterval seconds = [location.timestamp timeIntervalSince1970];
      self.timestamp = (NSInteger)ceil(seconds * 1000);

      self.failed = NO;

      CFRunLoopStop(CFRunLoopGetCurrent());
    }
  }
}

- (void)locationManager:(CLLocationManager *)manager
  didFailWithError:(NSError *)error {
  // Don't care about heading so continue
  if (error.code == kCLErrorHeadingFailure) {
    return;
  }

  self.failed = YES;
  self.errorCode = error.code;

  CFRunLoopStop(CFRunLoopGetCurrent());
}

@end

CLLocationManager *locationManager = nil;

bool enableCoreLocation() {
  if ([CLLocationManager locationServicesEnabled]) {
    locationManager = [[CLLocationManager alloc] init];

    return true;
  }

  return false;
}

void getCurrentPosition(const FunctionCallbackInfo<Value>& args) {
  Isolate* isolate = args.GetIsolate();
  HandleScope scope(isolate);

  LocationManagerDelegate *delegate = [[LocationManagerDelegate alloc] init];

  if (args.Length() == 1) {
    if (args[0]->IsObject()) {
      Local<Object> options = args[0]->ToObject();

      Local<String> maximumAgeKey = String::NewFromUtf8(isolate, "maximumAge");
      if (options->Has(maximumAgeKey)) {
        // Anything less than 100ms doesn't make any sense
        delegate.maximumAge = MAX(
          100, options->Get(maximumAgeKey)->NumberValue()
        );
        delegate.maximumAge /= 1000;
      }

      Local<String> enableHighAccuracyKey = String::NewFromUtf8(
        isolate, "enableHighAccuracy"
      );
      if (options->Has(enableHighAccuracyKey)) {
        delegate.enableHighAccuracy = options->Get(
          enableHighAccuracyKey
        )->BooleanValue();
      }

    }
  }

  if (!enableCoreLocation()) {
    isolate->ThrowException(
      Exception::TypeError(
        String::NewFromUtf8(isolate, "CLocationErrorNoLocationService")
      )
    );
    return;
  }

  if (delegate.enableHighAccuracy) {
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
  }

  [locationManager setDelegate:delegate];
  [locationManager startUpdatingLocation];

  // Block until all the sources and timers are removed from the main run loop
  CFRunLoopRun();

  [locationManager stopUpdatingLocation];

  if ([delegate hasFailed]) {
    switch (delegate.errorCode) {
      case kCLErrorDenied:
        isolate->ThrowException(
            Exception::TypeError(
              String::NewFromUtf8(
                isolate,
                "CLocationErrorLocationServiceDenied"
              )
            )
        );
        return;
      case kCLErrorLocationUnknown:
        isolate->ThrowException(
            Exception::TypeError(
              String::NewFromUtf8(isolate, "CLocationErrorLocationUnknown")
            )
        );
        return;
      default:
        isolate->ThrowException(
            Exception::TypeError(
              String::NewFromUtf8(isolate, "CLocationErrorLookupFailed")
            )
        );
        return;
      }
  }

  Local<Object> obj = Object::New(isolate);
  obj->Set(
    String::NewFromUtf8(isolate, "latitude"),
    Number::New(isolate, delegate.latitude)
  );
  obj->Set(
    String::NewFromUtf8(isolate, "longitude"),
    Number::New(isolate, delegate.longitude)
  );
  obj->Set(
    String::NewFromUtf8(isolate, "altitude"),
    Number::New(isolate, delegate.altitude)
  );
  obj->Set(
    String::NewFromUtf8(isolate, "horizontalAccuracy"),
    Number::New(isolate, delegate.horizontalAccuracy)
  );
  obj->Set(
    String::NewFromUtf8(isolate, "verticalAccuracy"),
    Number::New(isolate, delegate.verticalAccuracy)
  );
  obj->Set(
    String::NewFromUtf8(isolate, "timestamp"),
    Number::New(isolate, delegate.timestamp)
  );

  args.GetReturnValue().Set(obj);
}

void Initialise(Handle<Object> exports) {
  NODE_SET_METHOD(exports, "getCurrentPosition", getCurrentPosition);
}

NODE_MODULE(macos_clocation_wrapper, Initialise)
