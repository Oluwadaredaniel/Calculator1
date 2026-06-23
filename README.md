# Material Calculator (assignment_001)

A calculator built with Google's **Material design**, with a light and a dark
mode you can switch from the top corner.

## What it does

- Add, subtract, multiply, divide
- A **Scientific** keypad — sin, cos, tan (in degrees or radians), sinh, cosh,
  tanh, logs, powers, square root, factorial, π and e
- **Permutations and combinations** — type them as `5P2` or `5C2`
- A **Matrix** screen (2×2 to 4×4: add, subtract, multiply, determinant, transpose)
- A **Statistics** screen (mean, median, mode, range, standard deviation, and more)

## How it's built

The main screen keeps track of what you type using Flutter's built-in
`setState`. The matrix and statistics tools each live on their own screen,
reached from the icons at the top.

```
lib/
  main.dart / app.dart   – starting point and theme
  theme/                 – colours and fonts
  services/              – the actual maths (arithmetic, scientific, matrix, statistics)
  widgets/               – the buttons and the display
  screens/               – calculator, matrix, statistics
```

## How to run

```
flutter create .
flutter pub get
flutter run
```

No extra packages. Needs Flutter 3.22 or newer.
