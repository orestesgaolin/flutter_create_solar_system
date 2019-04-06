import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void main() => runApp(MA());

class Plnt {
  int i;
  String nm;
  String fl;
  double sz;
  double rd;
  Color clr;
  String ds;
  Plnt(this.i, Map<String, dynamic> d, this.clr) {
    nm = d['name'];
    fl = d['file'];
    sz = d['sz'];
    rd = d['rd'];
    ds = d['desc'];
  }
}

class MA extends StatefulWidget {
  _MAState createState() => _MAState();
}

class _MAState extends State<MA> {
  Map<String, dynamic> data;
  List<Plnt> ps = [];
  bool blur;
  @override
  void initState() {
    super.initState();
    DefaultAssetBundle.of(context).loadString('data.json').then(
      (s) {
        data = json.decode(s);
        setState(
          () {
            ps = [
              Plnt(0, data['0'], Colors.grey),
              Plnt(1, data['1'], Colors.orange),
              Plnt(2, data['2'], Colors.blue),
              Plnt(3, data['3'], Colors.red),
              Plnt(4, data['4'], Colors.brown),
              Plnt(5, data['5'], Colors.yellow),
              Plnt(6, data['6'], Colors.blue),
              Plnt(7, data['7'], Colors.cyan),
              Plnt(8, data['8'], Colors.grey),
            ];
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) return Container();

    var pStck = ps.map((p) => Orbt(p, setState) as Widget).toList();

    pStck.add(Text(
      data['title'],
      style: TextStyle(fontSize: 40),
      textAlign: TextAlign.center,
    ));
    return MaterialApp(
      theme:
          ThemeData(canvasColor: Colors.transparent, brightness: Brightness.dark, fontFamily: 'j'),
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black,
                      image: DecorationImage(image: AssetImage(data['bg']), fit: BoxFit.cover)),
                  width: 2000,
                  height: 3000,
                  child: Stack(
                    children: pStck,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Orbt extends HookWidget {
  Plnt p;
  void Function(VoidCallback fn) setState;
  Orbt(
    this.p,
    this.setState, {
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final AnimationController controller = useAnimationController(
      duration: Duration(seconds: p.i * 4 + 2),
      lowerBound: 2.8,
      upperBound: 5,
    );
    useEffect(() {
      controller.repeat();
    }, [controller]);
    double value = useAnimation(controller);
    return Stack(
      children: <Widget>[
        Positioned(
          right: -p.rd / 2,
          bottom: -p.rd / 2,
          child: IgnorePointer(
            child: AnimatedContainer(
              duration: Duration(seconds: 1),
              width: p.rd,
              height: p.rd,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, border: Border.all(color: p.clr, width: 1)),
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Transform(
            transform: Matrix4.translationValues(
              p.rd / 2 * cos(value) + p.sz / 2,
              p.rd / 2 * sin(value) + p.sz / 2,
              0,
            ),
            child: AnimatedContainer(
              duration: Duration(seconds: 1),
              width: p.sz,
              height: p.sz,
              child: RotationTransition(
                turns: controller,
                child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          opaque: false,
                          // transitionDuration: Duration(milliseconds: 600),
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
                                            p.nm,
                                            style: TextStyle(fontSize: 40, fontFamily: 'b'),
                                          ),
                                          Hero(tag: p.i, child: Image.asset(p.fl)),
                                          txt(p.ds),
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
                    },
                    child: Hero(
                      tag: p.i,
                      child: Image.asset(
                        p.fl,
                      ),
                    )),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Padding txt(String d) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(d),
    );
  }
}
