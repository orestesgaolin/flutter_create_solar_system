# Solar System Explorer
Flutter Create submission in 3838 KB of Dart code (after minification).

## Let's go for a ride through the Solar System

This app allows you to explore planets of the Solar System (_Pluto included_). Planets' sizes and distances from the Sun are arbitrary but orbital periods are preserved down to one Earth day (1 second is 1 day initially). You can control the speed of animation by tapping buttons on the bottom of the screen.

App was developed as a submission to Flutter Create contest. At the time of the project I was still learning Flutter and actually this was one of the first apps I made.


## Technical details

It uses custom Flare animations, flutter_hooks and matrix_gesture_detector.

Planet icons were bought on Iconfinder and then animated by me (and some of them were redrawn from scratch) in [Flare](https://www.2dimensions.com/).

Planetary data was taken from Wikipedia.

## Assumptions

- I had to give up on code quality - there are some dirty hacks and workarounds applied to fit in 5 KB limit
- Most of the data is kept in `data.json` file and then accessed from dynamic Map - usually you would use some kind of [json serialization mechanism](https://flutter.dev/docs/development/data-and-backend/json)
- Minified code fits in single line with no extra spaces, single character names and badly formatted constructors - you wouldn't do this typically in jor day to day job ;)
- Everything is stored in a single file
- No extracted custom widgets etc. and only couple of functions
- [flutter_hooks](https://pub.dartlang.org/packages/flutter_hooks) to the rescue - it removed unnecessary boilerplate when using animation controllers

## Problems during development

- `Transform` widget doesn't allow to detect taps (hits) outside its boundaries (see [this issue](https://github.com/flutter/flutter/issues/6606)), so I had to fit everything inside 
- Flare actors (animations) stutter when using Hero with them
- Widget disappears from original spot when animating with Hero - probably you could solve this by keeping two copies of the widget in Stack and apply Hero to one of them
- Some trigonometry knowledge required to revolve planets around the Sun ;)

