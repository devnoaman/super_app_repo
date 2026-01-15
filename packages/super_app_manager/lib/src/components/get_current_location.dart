import 'dart:async';
import 'dart:developer';

import 'package:easy_debouncer/easy_debouncer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'
    hide NumDurationExtensions;
// import 'package:dynamic_views/extenstions.dart' hide NumDurationExtensions;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart' hide Marker;
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:super_app_manager/src/utils/extentions.dart';

class GetCurrentLocation extends StatefulWidget {
  const GetCurrentLocation({super.key});

  @override
  State<GetCurrentLocation> createState() => _GetCurrentLocationState();
}

class _GetCurrentLocationState extends State<GetCurrentLocation>
    with SingleTickerProviderStateMixin {
  final Completer<GoogleMapController> _controller = Completer();
  AnimationController? _animationController;
  @override
  void initState() {
    _animationController = AnimationController(vsync: this);
    setLocation();
    super.initState();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  var position = const CameraPosition(
    target: LatLng(0, 0),
  );
  setLocation() async {
    var loc = await _getCurrentLocation();
    if (mounted) {
      Future.delayed(Durations.long1, () {
        _controller.future.then((controller) {
          controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(loc.latitude, loc.longitude),
                zoom: 15,
              ),
            ),
          );
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(4.0),
          child: FloatingActionButton(
            elevation: 0,
            onPressed: () {
              Navigator.pop(context);
            },
            shape: const CircleBorder(),
            child: const Icon(Icons.arrow_back),
          ),
        ),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: position,
            zoomControlsEnabled: false,
            onCameraMoveStarted: () {
              // Debouncer.debounce('map-debounce', Durations.long4, () {
              _animationController?.reverse();
              // });

              // set state that the user is moving the camera
              log('camera moving');
            },
            onCameraMove: (p) {
              log(p.target.toString());
              position = p;
              setState(() {});
              Debouncer.debounce('map-debounce', Durations.long4, () {});
            },
            onCameraIdle: () {
              _animationController?.forward();
              log('camera idle');
            },
            padding: const EdgeInsets.all(24),
            myLocationButtonEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child:
                  Align(
                        alignment: Alignment.bottomCenter,
                        child: Material(
                          clipBehavior: Clip.hardEdge,
                          surfaceTintColor: Colors.transparent,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: SizedBox(
                            height: 150,
                            width: context.width,
                            // color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Select this location',
                                    style: context.textTheme.bodyLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: context.theme.primaryColor,
                                        ),
                                  ),
                                  const Spacer(),
                                  RawMaterialButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    fillColor: Theme.of(context).primaryColor,
                                    onPressed: () {
                                      Navigator.pop(context, position.target);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Iconsax.location,
                                            color: Colors.white,
                                          ),
                                          8.wGap,
                                          const Text(
                                            'Set Location',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      .animate(
                        controller: _animationController,
                      )
                      .slideY(
                        duration: 1000.ms,
                        begin: 200,
                        end: 0,
                      ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Lottie.asset(
                '/lib/assets/lottie/location.json',
                width: 45,
                height: 45,
                package: 'super_app_manager',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    geolocator.LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openAppSettings();

      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    var loc = await Geolocator.getCurrentPosition();
    log('loc$loc');
    return loc;
  }
}
