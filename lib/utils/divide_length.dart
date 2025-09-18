double divideLength({
  required double length,
  required double itemCount,
  required double spacing,
}) {
  return (length - (itemCount - 1) * spacing) / itemCount;
}
