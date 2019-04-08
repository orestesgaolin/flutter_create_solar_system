# Solar System Explorer
Flutter Create submission in 3838 KB of Dart code (after minification).

It uses custom Flare animations, flutter_hooks and matrix_gesture_detector.

Planet icons bought on Iconfinder and the animated by me (and some of them redrawn from scratch) in Flare.

## Assumptions

- I had to give up on code quality - there are some dirty hacks and workarounds applied to fit in 5 KB limit
- Most of the data is kept in data.json file and then accessed from dynamic `Map<String,dynamic>`. Usually you would use some kind of [json serialization mechanism](https://flutter.dev/docs/development/data-and-backend/json)
