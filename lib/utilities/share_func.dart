class ShareFunc {
  double calculateWithKDV(num value, num kdv) {
    return value + (value * (kdv / 100));
  }

  double calculateWithoutKDV(num value, num kdv) {
    return value / ((100 + kdv) / 100);
  }
}

final shareFunc = ShareFunc();
