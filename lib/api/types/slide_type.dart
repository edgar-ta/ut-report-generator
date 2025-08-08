enum SlideType { failureRate, average }

SlideType slideTypeFromString(String type) {
  switch (type) {
    case 'failure_rate':
      return SlideType.failureRate;
    case 'average':
      return SlideType.average;
    default:
      throw ArgumentError('Unknown slide type: $type');
  }
}
