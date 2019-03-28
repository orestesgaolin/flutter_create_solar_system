import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

void main() => runApp(MA());

class MA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HP(),
    );
  }
}

class HP extends StatefulWidget {
  @override
  _HPState createState() => _HPState();
}

class Planet {
  int i;
  String nm;
  double sz;
  double rd;
  double pd;
  Color clr;
  Animation<double> an;
  bool v = false;
  Planet(this.i, this.nm, this.sz, this.rd, this.clr);
}

class _HPState extends State<HP> with SingleTickerProviderStateMixin {
  AnimationController ctrl;
  List<Planet> planets = [];

  @override
  void initState() {
    super.initState();
    ctrl = AnimationController(duration: const Duration(seconds: 20), vsync: this);

    planets = [
      Planet(0, 'uran', 16, 200, Colors.grey),
      Planet(1, 'venus', 38, 480, Colors.orange),
      Planet(2, 'earth2', 40, 800, Colors.blue),
      Planet(3, 'mars', 22, 1000, Colors.red),
      Planet(4, 'jupiter', 100, 1600, Colors.orange),
      Planet(5, 'earth', 40, 2000, Colors.blue),
      Planet(6, 'earth', 40, 2500, Colors.blue),
      Planet(7, 'pluto', 20, 3050, Colors.blue),
    ];
    planets.forEach((f) => addTween(f));

    ctrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    var pStck = planets.map((p) => Orbit(p, ctrl, setState) as Widget).toList();
    if (planets.any((n) => n.v == true)) {
      pStck.add(IgnorePointer(
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              decoration: BoxDecoration(color: Colors.black26),
            ),
          ),
        ),
      ));
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: GestureDetector(
            onTap: () {
              ctrl.forward();
              planets.forEach((n) => n.v = false);
            },
            child: Container(
              decoration: BoxDecoration(color: Colors.black),
              width: 500,
              height: 2000,
              child: Stack(
                children: pStck,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void addTween(Planet f) {
    var begin = f.i > 2 ? atan(600 / f.rd) : pi;
    var tween = Tween<double>(begin: 1.4 * pi - begin, end: 1.55 * pi).animate(
      CurvedAnimation(
        parent: ctrl,
        curve: Interval(
          f.i%2 == 0 ? 0.0 : 0.2,
          f.i%2 == 0 ? 0.8 : 1.0,
        ),
      ),
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          ctrl.repeat();
        }
      });
    f.an = tween;
  }

  @override
  void dispose() {
    super.dispose();
    ctrl.dispose();
  }
}

class Orbit extends StatelessWidget {
  Planet planet;
  AnimationController ctrl;
  void Function(VoidCallback fn) setState;

  Orbit(
    this.planet,
    this.ctrl,
    this.setState, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          right: 0,
          bottom: 0,
          child: CustomPaint(
            foregroundPainter: MyPainter(planet.clr, planet.sz, planet.an),
            child: SizedBox(
              width: planet.rd,
              height: planet.rd,
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Transform(
            transform: Matrix4.translationValues(
                planet.rd / 2 * cos(planet.an.value) + planet.sz / 2,
                planet.rd / 2 * sin(planet.an.value) + planet.sz / 2,
                0),
            child: Container(
              width: planet.sz,
              height: planet.sz,
              child: RotationTransition(
                turns: planet.an,
                child: GestureDetector(
                  onTap: () async {
                    if (ctrl.velocity > 0.02)
                      ctrl.stop();
                    else
                      ctrl.forward();
                    setState(() {
                      planet.v = !planet.v;
                    });
                    // Navigator.of(context).push(FadeRouteBuilder(page: NewPage()));
                  },
                  child: Image.asset(
                    'assets/${planet.nm}.png',
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FadeRouteBuilder<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeRouteBuilder({@required this.page})
      : super(
          pageBuilder: (context, a1, a2) => page,
          transitionsBuilder: (context, a1, a2, child) {
            return FadeTransition(opacity: a1, child: child);
          },
        );
}

class MyPainter extends CustomPainter {
  Color lineColor;
  double width;
  Animation<double> animation;

  MyPainter(this.lineColor, this.width, this.animation);
  @override
  void paint(Canvas canvas, Size size) {
    Paint line = new Paint()
      ..color = lineColor.withAlpha(80)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    // Offset center = new Offset(size.width, size.height);
    // double radius = min(size.width / 2, size.height / 2);
    Rect rect = new Rect.fromLTWH(size.width / 2, size.height / 2, size.width, size.height);
    canvas.drawOval(rect, line);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
