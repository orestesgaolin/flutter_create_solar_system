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

class Plnt {
  int i;
  String nm;
  double sz;
  double rd;
  double pd;
  Color clr;
  Animation<double> an;
  bool v = false;
  Plnt(this.i, this.nm, this.sz, this.rd, this.clr);
}

class _HPState extends State<HP> with SingleTickerProviderStateMixin {
  AnimationController ctrl;
  List<Plnt> ps = [];
  @override
  void initState() {
    super.initState();
    ctrl = AnimationController(duration: const Duration(seconds: 20), vsync: this);
    ps = [
      Plnt(0, 'uran', 16, 200, Colors.grey),
      Plnt(1, 'venus', 38, 480, Colors.orange),
      Plnt(2, 'earth2', 40, 800, Colors.blue),
      Plnt(3, 'mars', 22, 1000, Colors.red),
      Plnt(4, 'jupiter', 100, 1600, Colors.orange),
      Plnt(5, 'earth', 40, 2000, Colors.deepOrange),
      Plnt(6, 'earth', 40, 2500, Colors.purple),
      Plnt(7, 'pluto', 20, 3050, Colors.grey),
    ];
    ps.forEach((f) => addTween(f));
    ctrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    var pStck = ps.map((p) => Orbt(p, ctrl, setState) as Widget).toList();
    if (ps.any((n) => n.v == true)) {
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

    pStck.add(AnimatedOpacity(
      opacity: ctrl.value,
      duration: Duration(seconds: 10),
      child: Text(
        "\nLet' go for a ride through space!",
        style: TextStyle(fontSize: 40, color: Colors.white, fontStyle: FontStyle.italic),
        textAlign: TextAlign.center,
      ),
    ));
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: GestureDetector(
            onTap: () {
              ctrl.forward();
              ps.forEach((n) => n.v = false);
            },
            child: Container(
              decoration: BoxDecoration(color: Colors.black),
              width: 400,
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

  void addTween(Plnt f) {
    var begin = f.i > 2 ? atan(400 / f.rd) : pi;
    var tween = Tween<double>(begin: 1.35 * pi - begin, end: 1.55 * pi).animate(
      CurvedAnimation(
        parent: ctrl,
        curve: Interval(
          f.i % 2 == 0 ? 0.0 : 0.1,
          f.i % 2 == 0 ? 0.9 : 1.0,
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

class Orbt extends StatelessWidget {
  Plnt p;
  AnimationController ctrl;
  void Function(VoidCallback fn) setState;
  Orbt(
    this.p,
    this.ctrl,
    this.setState, {
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Positioned(
        //   right: 0,
        //   bottom: 0,
        //   child: CustomPaint(
        //     foregroundPainter: MyPainter(p.clr, p.sz, p.an),
        //     child: SizedBox(
        //       width: p.rd,
        //       height: p.rd,
        //     ),
        //   ),
        // ),
        Positioned(
          right: -p.rd/2,
          bottom: -p.rd/2,
          child: Container(
            width: p.rd,
            height: p.rd,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: p.clr, width: 1)
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Transform(
            transform: Matrix4.translationValues(
                p.rd / 2 * cos(p.an.value) + p.sz / 2, p.rd / 2 * sin(p.an.value) + p.sz / 2, 0),
            child: Container(
              width: p.sz,
              height: p.sz,
              child: RotationTransition(
                turns: p.an,
                child: GestureDetector(
                  onTap: () async {
                    if (ctrl.velocity > 0.02)
                      ctrl.stop();
                    else
                      ctrl.forward();
                    setState(() {
                      p.v = !p.v;
                    });
                  },
                  child: Image.asset(
                    'assets/${p.nm}.png',
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
  final Widget p;
  FadeRouteBuilder({@required this.p})
      : super(
          pageBuilder: (context, a1, a2) => p,
          transitionsBuilder: (context, a1, a2, child) {
            return FadeTransition(opacity: a1, child: child);
          },
        );
}

class MyPainter extends CustomPainter {
  Color lC;
  double w;
  Animation<double> a;
  MyPainter(this.lC, this.w, this.a);
  @override
  void paint(Canvas c, Size s) {
    Paint l = new Paint()
      ..color = lC.withAlpha(80)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    Rect r = new Rect.fromLTWH(s.width / 2, s.height / 2, s.width, s.height);
    c.drawOval(r, l);
  }

  @override
  bool shouldRepaint(CustomPainter oD) {
    return true;
  }
}
