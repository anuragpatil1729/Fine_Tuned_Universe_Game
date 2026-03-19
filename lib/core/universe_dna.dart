// WHAT: Utility class for universe DNA generation and parsing.
// WHY: Allows universes to be represented as 6-char alphanumeric seeds for sharing and deterministic positioning.

class UniverseDNA {
  static String generate(
    double gravity,
    double nuclear,
    double em,
    double entropy,
    double darkEnergy,
  ) {
    const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    int encode(double val) {
      return (val.clamp(0.0, 0.999) * 36).toInt();
    }

    final g = encode(gravity);
    final n = encode(nuclear);
    final e = encode(em);
    final s = encode(entropy);
    final d = encode(darkEnergy);

    // 6th char: XOR checksum of the 5 encoded values
    final checksum = (g ^ n ^ e ^ s ^ d) % 36;

    return [
      chars[g],
      chars[n],
      chars[e],
      chars[s],
      chars[d],
      chars[checksum],
    ].join();
  }

  static Map<String, double> parse(String dna) {
    if (dna.length != 6) return {};
    const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    double decode(String char) {
      int index = chars.indexOf(char.toUpperCase());
      if (index == -1) return 0.5;
      return index / 36.0;
    }

    return {
      'gravity': decode(dna[0]),
      'nuclear': decode(dna[1]),
      'em': decode(dna[2]),
      'entropy': decode(dna[3]),
      'darkEnergy': decode(dna[4]),
    };
  }

  static bool isValid(String dna) {
    if (dna.length != 6) return false;
    const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final values = dna
        .substring(0, 5)
        .split('')
        .map((c) => chars.indexOf(c.toUpperCase()))
        .toList();
    if (values.any((v) => v == -1)) return false;
    int checksum = values.reduce((a, b) => a ^ b) % 36;
    return chars[checksum] == dna[5].toUpperCase();
  }
}
