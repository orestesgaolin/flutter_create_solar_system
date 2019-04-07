import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:flare_flutter/flare_actor.dart';

void main() => runApp(MA());

class P {
  int i, y;
  String n, f, l, ds;
  double s, r;
  Color c;
  P(Map<String, dynamic> d) {
    n = d['n'];
    y = d['y'];
    f = d['f'];
    l = d['l'];
    s = d['s'] / 12;
    r = d['r'] / 12;
    ds = d['d'];
    i = d['i'];
    c = Color(d['c']);
  }
}

class MA extends StatefulWidget {
  _MAState createState() => _MAState();
}

class _MAState extends State<MA> {
  double scale = 1.0;
  Map<String, dynamic> data;
  List<P> p = [];
  bool blur;
  final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
  @override
  void initState() {
    super.initState();
    DefaultAssetBundle.of(context).loadString('data.json').then((s) {
      data = json.decode(s);
      setState(() {
        [0, 1, 2, 3, 4].forEach((i) => p.add(P(data['$i'])));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) return Container();

    var pS = p.map((p) => O(p, setState)).toList();

    return MaterialApp(
        theme: ThemeData(
            canvasColor: Colors.transparent, brightness: Brightness.dark, fontFamily: 'j'),
        home: Scaffold(
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              RaisedButton(
                  child: Text('x 1/2'),
                  onPressed: () => setState(() {
                        scale = scale * 2;
                        timeDilation = scale;
                      })),
              Text('${1 / scale}'),
              RaisedButton(
                  child: Text('x 2'),
                  onPressed: () => setState(() {
                        scale = scale / 2;
                        timeDilation = scale;
                      }))
            ]),
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
                          return Transform(transform: notifier.value, child: Stack(children: pS));
                        })))));
  }
}

class O extends HookWidget {
  P p;
  void Function(VoidCallback fn) ss;
  O(this.p, this.ss, {Key key}) : super(key: key);
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
                    transform: Matrix4.translationValues(p.r / 2 * cos(v), p.r / 2 * sin(v), 0),
                    child: GestureDetector(
                        onTap: () => tp(context),
                        child: AnimatedContainer(
                            duration: Duration(seconds: 1),
                            width: p.s,
                            height: p.s,
                            child: Hero(
                              tag: p.i,
                              child: FlareActor(p.l,
                                  alignment: Alignment.center, fit: BoxFit.contain, animation: '1'),
                            )))))));
  }

  void tp(BuildContext ctx) {
    var s = timeDilation;
    timeDilation = 1.0;

    Navigator.of(ctx).push(PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (cc, _, __) {
          return WillPopScope(
              onWillPop: () => a(s),
              child: GestureDetector(
                  onTap: () => Navigator.pop(cc),
                  child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                      child: Scaffold(
                          body: GestureDetector(
                              onTap: () => Navigator.pop(cc),
                              child: Padding(
                                  padding: EdgeInsets.all(30),
                                  child: ListView(children: [
                                    Text(
                                      p.n,
                                      style: TextStyle(fontSize: 40, fontFamily: 'b'),
                                    ),
                                    Hero(
                                        tag: p.i,
                                        child: Container(
                                            width: 200,
                                            height: 200,
                                            child: FlareActor(p.l,
                                                alignment: Alignment.center,
                                                fit: BoxFit.contain,
                                                animation: '1'))),
                                    Padding(padding: EdgeInsets.all(8.0), child: Text(p.ds))
                                  ])))))));
        }));
  }

  Future<bool> a(double s) {
    timeDilation = s;
    return Future<bool>.value(true);
  }
}
