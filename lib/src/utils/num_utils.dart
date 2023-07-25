const verySmallNumber = 0.0000001;

bool isUnity(double num) {
  return num > (1.0 - verySmallNumber) && num < (1.0 + verySmallNumber);
}
