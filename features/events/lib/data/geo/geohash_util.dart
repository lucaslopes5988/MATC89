/// Geohash encoder using the standard base-32 algorithm.
/// Precision 9 (~4.77m) matches geoflutterfire conventions.
abstract final class GeohashUtil {
  static const _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

  static String encode(double latitude, double longitude, {int precision = 9}) {
    var latMin = -90.0;
    var latMax = 90.0;
    var lngMin = -180.0;
    var lngMax = 180.0;
    var isLng = true;
    var bit = 0;
    var charIndex = 0;
    final hash = StringBuffer();

    while (hash.length < precision) {
      if (isLng) {
        final mid = (lngMin + lngMax) / 2;
        if (longitude >= mid) {
          charIndex = charIndex * 2 + 1;
          lngMin = mid;
        } else {
          charIndex = charIndex * 2;
          lngMax = mid;
        }
      } else {
        final mid = (latMin + latMax) / 2;
        if (latitude >= mid) {
          charIndex = charIndex * 2 + 1;
          latMin = mid;
        } else {
          charIndex = charIndex * 2;
          latMax = mid;
        }
      }

      isLng = !isLng;
      bit++;

      if (bit == 5) {
        hash.write(_base32[charIndex]);
        bit = 0;
        charIndex = 0;
      }
    }

    return hash.toString();
  }
}
