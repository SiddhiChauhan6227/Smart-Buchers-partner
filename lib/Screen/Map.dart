import 'dart:async';
import 'dart:math';
import 'package:erestro/Screen/profile.dart' as profile;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Helper/Color.dart';
import '../Helper/session.dart';
import 'Authentication/restorentRegistration.dart' as register;

class MapScreen extends StatefulWidget {
  final double? latitude, longitude;
  final bool? from;

  const MapScreen({Key? key, this.latitude, this.longitude, this.from}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool fromRegistration = false;
  LatLng? latlong;
  late CameraPosition _cameraPosition;
  GoogleMapController? _controller;
  TextEditingController locationController = TextEditingController();
  final Set<Marker> _markers = {};

  Future getCurrentLocation() async {
    List<Placemark> placemark = await placemarkFromCoordinates(
      widget.latitude!,
      widget.longitude!,
    );

    if (mounted) {
      setState(
        () {
          latlong = LatLng(widget.latitude!, widget.longitude!);

          _cameraPosition = CameraPosition(target: latlong!, zoom: 15.0, bearing: 0);
          if (_controller != null) {
            _controller!.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
          }

          var address;
          address = placemark[0].name;
          address = address + ',' + placemark[0].subLocality;
          address = address + ',' + placemark[0].locality;
          address = address + ',' + placemark[0].administrativeArea;
          address = address + ',' + placemark[0].country;
          address = address + ',' + placemark[0].postalCode;

          locationController.text = address;
          _markers.add(
            Marker(
              markerId: const MarkerId('Marker'),
              position: LatLng(widget.latitude!, widget.longitude!),
            ),
          );
        },
      );
    }
  }

  @override
  void initState() {
    fromRegistration = widget.from ?? false;
    super.initState();

    _cameraPosition = const CameraPosition(target: LatLng(0, 0), zoom: 10.0);
    getCurrentLocation();
  }

  void _checkPermission(Function callback, BuildContext context) async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    } else if (permission == LocationPermission.deniedForever) {
    } else {
      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
      );
      var position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);
      callback();

      latlong = LatLng(position.latitude, position.longitude);

      _cameraPosition = CameraPosition(target: latlong!, zoom: 14.4746, bearing: 0);
      if (_controller != null) {
        _controller!.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(
        getTranslated(context, "Choose Location")!,
        context,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: [
                  (latlong != null)
                      ? GoogleMap(
                          initialCameraPosition: _cameraPosition,
                          onMapCreated: (GoogleMapController controller) {
                            _controller = (controller);
                            _controller!.animateCamera(
                              CameraUpdate.newCameraPosition(
                                _cameraPosition,
                              ),
                            );
                          },
                          markers: myMarker(),
                          onTap: (latLng) {
                            if (mounted) {
                              setState(
                                () {
                                  latlong = latLng;
                                },
                              );
                            }
                          },
                        )
                      : Container(),
                  Positioned.directional(
                    textDirection: Directionality.of(context),
                    end: width / 90.0,
                    top: height / 80.6,
                    child: InkWell(
                      onTap: () => _checkPermission(() async {}, context),
                      child: Container(
                        padding: const EdgeInsetsDirectional.all(5.0),
                        margin: const EdgeInsetsDirectional.only(end: 10),
                        decoration: BoxDecoration(
                            // color: Theme.of(context).colorScheme.onSurface
                        ),
                        child: const Icon(
                          Icons.my_location,
                          color: lightBlack,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            TextField(
              cursorColor: black,
              controller: locationController,
              readOnly: true,
              style: const TextStyle(
                color: fontColor,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                icon: Container(
                  margin: const EdgeInsetsDirectional.only(
                    start: 20,
                    top: 0,
                  ),
                  width: 10,
                  height: 10,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.green,
                  ),
                ),
                hintText: 'pick up',
                border: InputBorder.none,
                contentPadding: const EdgeInsetsDirectional.only(start: 15.0, top: 12.0),
              ),
            ),
            ElevatedButton(
              child: Text(
                getTranslated(context, "Update Location")!,
              ),
              onPressed: () {
                if (fromRegistration) {
                  register.latitutute = latlong!.latitude.toString();
                  register.longitude = latlong!.longitude.toString();
                } else {
                  profile.latitutute = latlong!.latitude.toString();
                  profile.longitude = latlong!.longitude.toString();
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Set<Marker> myMarker() {
    _markers.clear();

    _markers.add(
      Marker(
        markerId: MarkerId(Random().nextInt(10000).toString()),
        position: LatLng(latlong!.latitude, latlong!.longitude),
      ),
    );

    // getLocation();

    return _markers;
  }

  Future<void> getLocation() async {
    List<Placemark> placemark = await placemarkFromCoordinates(latlong!.latitude, latlong!.longitude);

    var address;
    address = placemark[0].name;
    address = address + ',' + placemark[0].subLocality;
    address = address + ',' + placemark[0].locality;
    address = address + ',' + placemark[0].administrativeArea;
    address = address + ',' + placemark[0].country;
    address = address + ',' + placemark[0].postalCode;
    locationController.text = address;
    if (mounted) {
      setState(
        () {},
      );
    }
  }
}
