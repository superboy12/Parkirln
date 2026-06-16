import 'package:intl/intl.dart';

class AppUtils {
  static String formatDate(DateTime dt) => DateFormat('dd MMM yyyy', 'id_ID').format(dt);
  static String formatTime(DateTime dt) => DateFormat('HH:mm').format(dt);
  static String formatDateTime(DateTime dt) => DateFormat('dd MMM yyyy, HH:mm').format(dt);
  static String formatDuration(Duration d) {
    if (d.inHours > 0) return '${d.inHours}j ${d.inMinutes.remainder(60)}m';
    return '${d.inMinutes}m';
  }
  static String formatCurrency(double amount) => 'Rp ${NumberFormat('#,###', 'id_ID').format(amount)}';

  static String slotStatusLabel(String status) {
    switch (status) {
      case 'available': return 'Tersedia';
      case 'reserved':  return 'Dipesan';
      case 'occupied':  return 'Terisi';
      default:          return 'Tidak Diketahui';
    }
  }
}
