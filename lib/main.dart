import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:flare_flutter/flare_actor.dart';

void main() => runApp(MA());

class Pt {
  int i, y;
  String n, f, l, ds;
  double s, r;
  Color c;
  Pt(Map<String, dynamic> d, this.c) {
    n = d['n'];
    y = d['y'];
    f = d['f'];
    l = d['l'];
    s = d['s'] / 12;
    r = d['r'] / 12;
    ds = d['d'];
    i = d['i'];
  }
}

class MA extends StatefulWidget {
  _MAState createState() => _MAState();
}

class _MAState extends State<MA> {
  Map<String, dynamic> data;
  List<Pt> ps = [];
  bool blur;
  final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
  @override
  void initState() {
    super.initState();
    DefaultAssetBundle.of(context).loadString('data.json').then(
      (s) {
        data = json.decode(s);
        setState(
          () {
            ps = [
              Pt(data['8'], Colors.grey),
              Pt(data['7'], Colors.cyan),
              Pt(data['6'], Colors.blue),
              Pt(data['5'], Colors.yellow),
              Pt(data['4'], Colors.brown),
              Pt(data['3'], Colors.red),
              Pt(data['2'], Colors.blue),
              Pt(data['1'], Colors.orange),
              Pt(data['0'], Colors.grey),
            ];
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) return Container();

    var pStck = ps.map((p) => Ot(p, setState) as Widget).toList();

    return MaterialApp(
      theme:
          ThemeData(canvasColor: Colors.transparent, brightness: Brightness.dark, fontFamily: 'j'),
      home: Scaffold(
        body: MatrixGestureDetector(
          shouldRotate: false,
          clipChild: true,
          onMatrixUpdate: (m, tm, sm, rm) {
            notifier.value = m;
          },
          child: Container(
            decoration: BoxDecoration(
                color: Colors.black,
                image: DecorationImage(image: AssetImage(data['bg']), fit: BoxFit.cover)),
            child: AnimatedBuilder(
              animation: notifier,
              builder: (context, child) {
                return Transform(
                  transform: notifier.value,
                  child: Stack(
                    children: pStck,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class Ot extends HookWidget {
  Pt p;
  void Function(VoidCallback fn) ss;
  Ot(
    this.p,
    this.ss, {
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final AnimationController c = useAnimationController(
      duration: Duration(seconds: p.y),
      lowerBound: 0,
      upperBound: 6.28,
    );
    useEffect(() {
      c.repeat();
    }, [c]);
    double v = useAnimation(c);
    return Center(
      child: Container(
        width: p.r,
        height: p.r,
        decoration:
            BoxDecoration(shape: BoxShape.circle, border: Border.all(color: p.c, width: 0.1)),
        child: Center(
          child: Transform(
            transform: Matrix4.translationValues(
              p.r / 2 * cos(v),
              p.r / 2 * sin(v),
              0,
            ),
            child: GestureDetector(
              onTap: () => tap(context),
              child: AnimatedContainer(
                duration: Duration(seconds: 1),
                width: p.s,
                height: p.s,
                child: RotationTransition(
                  turns: c,
                  child: Hero(
                    tag: p.i,
                    child: Image.asset(p.f),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void tap(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (context, _, __) {
          return GestureDetector(
            onTap: () => Navigator.pop(context),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: Scaffold(
                body: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: ListView(
                      children: <Widget>[
                        Text(
                          p.n,
                          style: TextStyle(fontSize: 40, fontFamily: 'b'),
                        ),
                        Hero(
                          tag: p.i,
                          child: Container(
                              width: 200,
                              height: 200,
                              child: FlareActor(
                                p.l,
                                alignment: Alignment.center,
                                fit: BoxFit.contain,
                                animation: '1',
                              )),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(p.ds),
                        ),
                      ],
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
}
