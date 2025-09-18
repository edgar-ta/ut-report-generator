double roundUp(double value) {
  if (value <= 100) {
    return (value / 10).ceil() * 10;
  } else {
    return (value / 100).ceil() * 100;
  }
}
