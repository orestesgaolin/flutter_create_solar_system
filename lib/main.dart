import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void main() => runApp(MA());

class MA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(canvasColor: Colors.transparent),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class Plnt {
  int i;
  String nm;
  double sz;
  double rd;
  double pd;
  Color clr;
  double op;
  Plnt(this.i, this.nm, this.sz, this.rd, this.clr);
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  List<Plnt> ps = [];
  bool blur;
  @override
  void initState() {
    super.initState();
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
  }

  @override
  Widget build(BuildContext context) {
    var pStck = ps.map((p) => Orbt(p, setState) as Widget).toList();

    pStck.add(AnimatedOpacity(
      opacity: 1,
      duration: Duration(seconds: 10),
      child: Text(
        "\nLet's go for a ride through space!",
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
            onTap: () {},
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
      duration: Duration(seconds: 10),
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
                          barrierDismissible: true,
                          pageBuilder: (context, _, __) {
                            return BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Scaffold(
                                body: Center(
                                  child: Column(
                                    children: <Widget>[
                                      Text(p.nm, style: TextStyle(color: Colors.white)),
                                      Hero(tag: p.i, child: Image.asset('assets/${p.nm}.png'))
                                    ],
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
                        'assets/${p.nm}.png',
                      ),
                    )),
              ),
            ),
          ),
        ),
      ],
    );
  }
}