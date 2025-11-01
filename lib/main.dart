import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const String title = 'Light & Dark Theme';

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MFU GemCar',
      themeMode: ThemeMode.system,
      theme: ThemeData(
          textTheme: TextTheme(headline1: TextStyle(color: Colors.black)),
          primarySwatch: Colors.red,
          appBarTheme: AppBarTheme(
            iconTheme: IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
            color: Color.fromARGB(255, 125, 41, 35), //เปลี่ยนสีแถบข้างบน
          )),
      home: const MyHomePage(
          title: 'MFU Gemcar'), //กำหนดให้ MyHomePage เป็นหน้าหลัก
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String googleAPiKey = "AIzaSyDJxO3TvhwDHN3apSu7zad3utTRUnh3QbU";

  final Completer<GoogleMapController> _controller = Completer();
  PolylinePoints polylinePoints = PolylinePoints();
  Set<Marker> markers = Set();
  Map<PolylineId, Polyline> polylines = {};

  static const LatLng sourceLocation =
      LatLng(20.04381035751123, 99.89355331631573);
  static const LatLng destination =
      LatLng(20.045783563672625, 99.89138322037833);

  LocationData? currentLocation;

  BitmapDescriptor gemIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor stationIcon = BitmapDescriptor.defaultMarker;
  void getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then(
      (location) {
        currentLocation = location;
      },
    );
    GoogleMapController googleMapController = await _controller.future;
    location.onLocationChanged.listen(
      (newLoc) {
        currentLocation = newLoc;
        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 16.5,
              target: LatLng(
                newLoc.latitude!,
                newLoc.longitude!,
              ),
            ),
          ),
        );
        setState(() {});
      },
    );
  }

  //ตอนนี้setCustomMarker เปิดใช้แล้วแอพจะเด้ง ก็คือยังเปลี่ยนไอคอน marker ไม่ได้/////

  void setCustomMarkerIcon() async {
    await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), "assets/redgem.png")
        .then((icon) {
      gemIcon = icon;
    });
    await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), "assets/busstop.png")
        .then((icon) {
      stationIcon = icon;
    });
  }

  @override
  void initState() {
    getCurrentLocation();
    getDirections();
    super.initState();
    setCustomMarkerIcon();
  }

  getDirections() async {
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Color.fromARGB(255, 150, 20, 20).withOpacity(0.5),
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), actions: [
        IconButton(
          icon: Icon(Icons.settings), //ปุ่มsettings ใน appbar
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Settings()));
          },
        ),
      ]),
      body: currentLocation == null
          ? const Center(child: Text("Loading"))
          : GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                  target: LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!),
                  zoom: 15.5),
              markers: {
                Marker(
                  markerId: const MarkerId("currentLocation"),
                  icon: gemIcon,
                  position: LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!),
                  infoWindow: InfoWindow(
                      title: "Gem 02", snippet: '2 mins until arrival'),
                ),
                Marker(
                  markerId: MarkerId("source"),
                  icon: stationIcon,
                  position: sourceLocation,
                  infoWindow: InfoWindow(
                    title: '13 จุดอาคาร E2 ขาออก',
                  ),
                ),
                Marker(
                    markerId: MarkerId("destination"),
                    icon: stationIcon,
                    position: destination,
                    infoWindow: InfoWindow(
                        title: '14 จุดอาคาร M-square', snippet: '2 min ETA ')),
                Marker(
                    markerId: MarkerId("01"),
                    icon: stationIcon,
                    position: LatLng(20.058841460019966, 99.8984495011412),
                    infoWindow: InfoWindow(title: '01 จุดหอพักลำดวน 2')),
                Marker(
                    markerId: MarkerId("02"),
                    icon: stationIcon,
                    position: LatLng(20.057081493877266, 99.89695553948428),
                    infoWindow: InfoWindow(title: '02 จุดหอพักลำดวน 7 ขาออก')),
                Marker(
                    markerId: MarkerId("03"),
                    icon: stationIcon,
                    position: LatLng(20.054684136270314, 99.8946019010731),
                    infoWindow:
                        InfoWindow(title: '03 จุด 3 แยกบ้านพักบุคลากร')),
                Marker(
                    markerId: MarkerId("04"),
                    icon: stationIcon,
                    position: LatLng(20.05230689898669, 99.89225362711254),
                    infoWindow: InfoWindow(title: '04 จุดอาคารพิพิธภัณฑ์ D2')),
              },
              polylines: Set<Polyline>.of(polylines.values),
              onMapCreated: (mapController) {
                _controller.complete(mapController);
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {}, label: Text('เปลี่ยนสาย')),
    );
  }
}

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _unfocusNode = FocusNode();
  bool _isDark = false;
  // Initial Selected Value

  // List of items in our dropdown menu

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), actions: [
        IconButton(
          icon: Icon(Icons.settings), //ปุ่มsettings ใน appbar
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ]),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(_unfocusNode),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 35, 0, 0),
                child: SwitchListTile(
                  value: _isDark,
                  onChanged: (bool value) async {
                    setState(() {
                      _isDark = value;
                    });
                  },
                  title: Text(
                    'Darkmode',
                    textAlign: TextAlign.start,
                  ),
                  tileColor: Colors.white,
                  dense: false,
                  controlAffinity: ListTileControlAffinity.trailing,
                  contentPadding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                ),
              ),
              ListTile(
                title: Text(
                  'Language',
                  textAlign: TextAlign.start,
                ),
                dense: false,
                trailing: Icon(Icons.chevron_right),
                tileColor: Colors.white,
              )
            ],
          ),
        ),
      ),
    );
  }
}



/*
class Settings extends StatelessWidget {
  const Settings({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), actions: [
        IconButton(
          icon: Icon(Icons.settings), //ปุ่มsettings ใน appbar
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ]),

/*---------------------------------------------setting--------------------------*/
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 35, 0, 0),
                child: SwitchListTile(
                  value: _isDarkmode,
                  onChanged: (bool value) async {
                    setState(() {_isDarkmode = value});
                  },
                  title: Text(
                    'Darkmode',
                    textAlign: TextAlign.start,
                    style: FlutterFlowTheme.of(context).title3.override(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                        ),
                  ),
                  tileColor: Colors.white,
                  dense: false,
                  controlAffinity: ListTileControlAffinity.trailing,
                  contentPadding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0, 0),
                child: FlutterFlowDropDown<String>(
                  options: ['Option 1'],
                  onChanged: (val) =>
                      setState(() => _model.dropDownValue = val),
                  width: double.infinity,
                  height: 50,
                  textStyle: FlutterFlowTheme.of(context).bodyText1.override(
                        fontFamily: 'Poppins',
                        color: Colors.black,
                        fontSize: 20,
                      ),
                  hintText: 'Language',
                  fillColor: Colors.white,
                  elevation: 2,
                  borderColor: Colors.transparent,
                  borderWidth: 0,
                  borderRadius: 0,
                  margin: EdgeInsetsDirectional.fromSTEB(12, 4, 12, 4),
                  hidesUnderline: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/

//static const keylanguage
/*Widget buildLanguage() => SwitchSettingsTile(
      settingKey: keylanguage,
      leading: IconWidget(icon: Icons.language, color: Colors.blueAccent),
      title: 'Language',
      onChange: (isLanguage) {},
    );*/
