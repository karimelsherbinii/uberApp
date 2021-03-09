import 'dart:io';

//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:uber_app/brand_colors.dart';
import 'package:uber_app/dataprovider/appdata.dart';
import 'package:uber_app/helpers/helpermethods.dart';
import 'package:uber_app/screens/searchPage.dart';
import 'package:uber_app/styles/Styles.dart';
import 'package:uber_app/widgets/BrandDivier.dart';
import 'package:uber_app/widgets/progressDialog.dart';
//import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MainPage extends StatefulWidget {
  // final FirebaseApp app;
  // MainPage({this.app});
  static const String id = 'mainPage';
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>(); // for drawer
  double searchSheetHeight = (Platform.isIOS) ? 300 : 275;
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;

  double mapBottomPadding = 0;
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  Set<Marker> _Markers = {};
  Set<Circle> _Circles = {};
  var geoLocator = Geolocator();
  Position currentPosition;

  void setupPositionLocator() async {
    Position position = await geoLocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;
    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp =
        CameraPosition(target: pos, zoom: 14); // cp = camera position
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));

    String address =
        await HelperMethods.findCordinateAddress(position, context);
    print(address);
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  // static final CameraPosition _kLake = CameraPosition(
  //     bearing: 192.8334901395799,
  //     target: LatLng(37.43296265331129, -122.08832357078792),
  //     tilt: 59.440717697143555,
  //     zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: Container(
        width: 250,
        color: Colors.white,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.all(0),
            children: [
              Container(
                color: Colors.white,
                height: 160,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    children: [
                      Image.asset(
                        'images/user_icon.png',
                        height: 60,
                        width: 60,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Karim',
                            style: TextStyle(
                                fontSize: 20, fontFamily: 'Brand-Bold'),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text('View profile'),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              BrandDivider(),
              SizedBox(height: 10),
              ListTile(
                leading: Icon(
                  OMIcons.cardGiftcard,
                ),
                title: Text(
                  'Free Rides',
                  style: kDrawerItemStyle,
                ),
              ),
              ListTile(
                leading: Icon(
                  OMIcons.creditCard,
                ),
                title: Text(
                  'Payments',
                  style: kDrawerItemStyle,
                ),
              ),
              ListTile(
                leading: Icon(
                  OMIcons.history,
                ),
                title: Text(
                  'Ride History',
                  style: kDrawerItemStyle,
                ),
              ),
              ListTile(
                leading: Icon(
                  OMIcons.contactSupport,
                ),
                title: Text(
                  'Support',
                  style: kDrawerItemStyle,
                ),
              ),
              ListTile(
                leading: Icon(
                  OMIcons.info,
                ),
                title: Text(
                  'About',
                  style: kDrawerItemStyle,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapBottomPadding),
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            mapType: MapType.normal,
            polylines: _polylines,
            markers: _Markers,
            circles: _Circles,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mapController = controller;
              setState(() {
                mapBottomPadding = (Platform.isAndroid) ? 280 : 270;
              });
              setupPositionLocator();
            },
          ),

          /// menuBotton
          Positioned(
            top: 44,
            left: 20,
            child: GestureDetector(
              onTap: () {
                scaffoldKey.currentState.openDrawer();
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5.0,
                        spreadRadius: 0.5,
                        offset: Offset(
                          0.7,
                          0.7,
                        ),
                      ),
                    ]),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.menu,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),

          /// search sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: searchSheetHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15.0,
                    spreadRadius: 0.5,
                    offset: Offset(
                      0.7,
                      0.7,
                    ),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Nice to see you!',
                      style: TextStyle(fontSize: 10),
                    ),
                    Text(
                      'where are you going ?',
                      style: TextStyle(fontFamily: 'Brand-bold', fontSize: 18),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () async {
                        // async bec i want make a condetion
                        var response = await Navigator.push(context,
                            MaterialPageRoute(builder: (ctx) => SearchPage()));

                        if (response == 'getDirection') {
                          await getDirection(); // this condetion for wait directions
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5.0,
                                spreadRadius: 0.5,
                                offset: Offset(
                                  0.7,
                                  0.7,
                                ),
                              )
                            ]),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: Colors.blueAccent),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Search destination',
                                style: TextStyle(color: Colors.black54),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 22,
                    ),
                    Row(
                      children: [
                        Icon(
                          OMIcons.home,
                          color: BrandColors.colorDimText,
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Add home'),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                              'Your residential address ',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: BrandColors.colorDimText),
                            )
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    BrandDivider(),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Icon(
                          OMIcons.workOutline,
                          color: BrandColors.colorDimText,
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Add work'),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                              'Your office address ',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: BrandColors.colorDimText),
                            )
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getDirection() async {
    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination =
        Provider.of<AppData>(context, listen: false).destinationAddress;
    var pickLatLng = LatLng(pickup.latitude, pickup.longitude);
    var destenationLatLng = LatLng(
        destination.latitude,
        destination
            .longitude); // b3d ma 3araftohom ba2a a2dar ageb elbayanat mn helper method

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              status: 'Please wait...',
            ));

    // mn hna
    var thisDetails =
        await HelperMethods.getDirectionDetails(pickLatLng, destenationLatLng);
    Navigator.pop(context);
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results =
        polylinePoints.decodePolyline(thisDetails.encodedPoints);
    polylineCoordinates.clear();
    if (results.isNotEmpty) {
      results.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _polylines.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('polyid'),
        color: Color.fromARGB(255, 95, 109, 137),
        points: polylineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      _polylines.add(polyline);
    });
    LatLngBounds bounds;
    if (pickLatLng.latitude > destenationLatLng.latitude &&
        pickLatLng.longitude > destenationLatLng.longitude) {
      bounds =
          LatLngBounds(southwest: destenationLatLng, northeast: pickLatLng);
    } else if (pickLatLng.longitude > destenationLatLng.longitude) {
      bounds = LatLngBounds(
        southwest: LatLng(pickLatLng.latitude, destenationLatLng.longitude),
        northeast: LatLng(destenationLatLng.latitude, pickLatLng.longitude),
      );
    } else if (pickLatLng.latitude > destenationLatLng.latitude) {
      bounds = LatLngBounds(
        southwest: LatLng(destenationLatLng.latitude, pickLatLng.longitude),
        northeast: LatLng(pickLatLng.latitude, destenationLatLng.longitude),
      );
    } else {
      bounds =
          LatLngBounds(southwest: pickLatLng, northeast: destenationLatLng);
    }
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
  }
}
