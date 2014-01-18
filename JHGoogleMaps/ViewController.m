//
//  ViewController.m
//  JHGoogleMaps
//
//  Created by Jason Humphries on 1/17/14.
//  Copyright (c) 2014 Humphries Data Design. All rights reserved.
//

#import "ViewController.h"
#import "MDDirectionService.h"

@interface ViewController () <GMSMapViewDelegate>
@property (strong, nonatomic) NSMutableArray *waypoints;
@property (strong, nonatomic) NSMutableArray *waypointStrings;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.waypoints = [NSMutableArray array];
    self.waypointStrings = [NSMutableArray array];
    
    // Create a GMSCameraPosition that tells the map to display the coordinate at zoom level 6
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:35.995602
                                                            longitude:-78.902153
                                                                 zoom:13];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.myLocationEnabled = YES;
    self.mapView.mapType = kGMSTypeNormal;
//    self.mapView.mapType = kGMSTypeHybrid;
//    self.mapView.mapType = kGMSTypeSatellite;
//    self.mapView.mapType = kGMSTypeTerrain;
//    self.mapView.mapType = kGMSTypeNone;
    self.mapView.indoorEnabled = YES;
    self.mapView.accessibilityElementsHidden = NO;
    self.mapView.settings.scrollGestures = YES;
    self.mapView.settings.zoomGestures = YES;
    self.mapView.settings.compassButton = YES;
    self.mapView.settings.myLocationButton = YES;
    self.mapView.delegate = self;
    self.view = self.mapView;
    
    [self placeMarkers];
    
    // padding
    // Insets are specified in this order: top, left, bottom, right
//    UIEdgeInsets mapInsets = UIEdgeInsetsMake(100.0, 0.0, 0.0, 300.0);
//    self.mapView.padding = mapInsets;
}

-(void)placeMarkers
{
    // Creates a marker in the center of the map
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(35.995602, -78.902153);
    marker.title = @"PopUp HQ";
    marker.snippet = @"Durham, NC";
    marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
//    marker.icon = [UIImage imageNamed:@"someicon.png"];
    marker.opacity = 0.9;
//    marker.flat = YES;
    marker.map = self.mapView;
}

#pragma mark - GMSMapViewDelegate

-(void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"you tapped at %f, %f", coordinate.longitude, coordinate.latitude);

    CLLocationCoordinate2D tapPosition = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);

    GMSMarker *tapMarker = [GMSMarker markerWithPosition:tapPosition];
    tapMarker.map = self.mapView;
    [self.waypoints addObject:tapMarker];

    NSString *positionString = [NSString stringWithFormat:@"%f,%f", coordinate.latitude,coordinate.longitude];
    [self.waypointStrings addObject:positionString];
    
    if (self.waypoints.count > 1) {
        NSDictionary *query = @{ @"sensor" : @"false",
                                 @"waypoints" : self.waypointStrings };
        MDDirectionService *mds = [[MDDirectionService alloc] init];
        SEL selector = @selector(addDirections:);
        [mds setDirectionsQuery:query
                   withSelector:selector
                   withDelegate:self];
    }
}

-(void)addDirections:(NSDictionary *)json
{
    NSDictionary *routes = json[@"routes"][0];
    NSDictionary *route = routes[@"overview_polyline"];
    NSString *overview_route = route[@"points"];
    GMSPath *path = [GMSPath pathFromEncodedPath:overview_route];
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    polyline.map = self.mapView;
}


-(void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture
{
//    [mapView clear];
}

-(void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
{
    NSLog(@"map became idle");
//    [self placeMarkers];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
