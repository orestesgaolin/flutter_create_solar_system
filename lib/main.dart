import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:flare_flutter/flare_actor.dart';

void main() => runApp(MA());

class Planet {
  int i, years;
  String name, flare, description;
  double size, radius;
  Color clr;
  Planet(Map<String, dynamic> d) {
    name = d['n'];
    years = d['y'];
    flare = d['l'];
    size = d['s'] / 12;
    radius = d['r'] / 12;
    description = d['d'];
    i = d['i'];
    clr = Color(d['c']);
  }
}

class MA extends StatefulWidget {
  _MAState createState() => _MAState();
}

class _MAState extends State<MA> {
  double scale = 1.0;
  Map<String, dynamic> data;
  List<Planet> p = [];
  final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
  @override
  void initState() {
    super.initState();
    DefaultAssetBundle.of(context).loadString('data.json').then(
      (string) {
        data = json.decode(string);
        setState(
          () {
            [9, 8, 7, 6, 5, 4, 3, 2, 1, 0].forEach(
              (i) => p.add(
                    Planet(data['$i']),
                  ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) return Container();
    var planetStack = p.map((p) => Orbit(p, setState)).toList();
    return MaterialApp(
      theme: ThemeData(
          canvasColor: Colors.transparent,
          brightness: Brightness.dark,
          fontFamily: 'j'),
      home: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text('Let\'s go for a ride through the Solar System!'),
            Text('Pan, zoom and tap to explore 🛰'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RaisedButton(
                  child: Text('x 1/2'),
                  onPressed: () => setState(
                        () {
                          scale = scale * 2;
                          timeDilation = scale;
                        },
                      ),
                ),
                Text('Time speed: ${1 / scale} yrs/s'),
                RaisedButton(
                  child: Text('x 2'),
                  onPressed: () => setState(
                        () {
                          scale = scale / 2;
                          timeDilation = scale;
                        },
                      ),
                )
              ],
            ),
          ],
        ),
        body: MatrixGestureDetector(
          shouldRotate: false,
          clipChild: true,
          onMatrixUpdate: (m, tm, sm, rm) {
            notifier.value = m;
          },
          child: Container(
            decoration: BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                    image: AssetImage(data['bg']), fit: BoxFit.cover)),
            child: AnimatedBuilder(
              animation: notifier,
              builder: (context, child) {
                return Transform(
                  transform: notifier.value,
                  child: Stack(children: planetStack),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class Orbit extends HookWidget {
  Planet planet;
  void Function(VoidCallback fn) setState;
  Orbit(this.planet, this.setState, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final AnimationController controller = useAnimationController(
      duration: Duration(seconds: planet.years),
      lowerBound: 0,
      upperBound: 6.28,
    );
    useEffect(() {
      controller.repeat();
    }, [controller]);
    double v = useAnimation(controller);
    return Center(
      child: Container(
        width: planet.radius,
        height: planet.radius,
        decoration: planet.i == 0
            ? BoxDecoration()
            : BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: planet.clr, width: 0.1),
              ),
        child: Center(
          child: Transform(
            transform: planet.i == 0
                ? Matrix4.identity()
                : Matrix4.translationValues(planet.radius / 2 * cos(v + 1),
                    planet.radius / 2 * sin(v + 1), 0),
            child: GestureDetector(
              onTap: () => tp(context),
              child: AnimatedContainer(
                duration: Duration(seconds: 1),
                width: planet.size,
                height: planet.size,
                child: Hero(
                  tag: planet.i,
                  child: FlareActor(planet.flare,
                      alignment: Alignment.center,
                      fit: BoxFit.contain,
                      animation: '1'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void tp(BuildContext ctx) {
    var s = timeDilation;
    timeDilation = 1.0;
    Navigator.of(ctx).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (cc, _, __) {
          return WillPopScope(
            onWillPop: () => a(s),
            child: GestureDetector(
              onTap: () => Navigator.pop(cc),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Scaffold(
                  body: GestureDetector(
                    onTap: () => Navigator.pop(cc),
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: ListView(
                        children: [
                          Text(
                            planet.name,
                            style: TextStyle(fontSize: 40, fontFamily: 'b'),
                          ),
                          Hero(
                            tag: planet.i,
                            child: Container(
                              width: 200,
                              height: 200,
                              child: FlareActor(planet.flare,
                                  alignment: Alignment.center,
                                  fit: BoxFit.contain,
                                  animation: '1'),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(planet.description),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool> a(double s) {
    timeDilation = s;
    return Future<bool>.value(true);
  }
}
