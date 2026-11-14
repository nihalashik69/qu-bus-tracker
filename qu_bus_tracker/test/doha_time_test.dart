import 'package:flutter_test/flutter_test.dart';
import 'package:qu_bus_tracker/doha_time.dart';
import 'package:qu_bus_tracker/schedule_service.dart';

void main() {
  group('DohaTime', () {
    test('uses the constant UTC+03:00 offset', () {
      expect(DohaTime.utcOffset, const Duration(hours: 3));
    });

    test('nowMinutesOfDay matches a manually shifted UTC clock', () {
      final doha = DateTime.now().toUtc().add(const Duration(hours: 3));
      expect(DohaTime.nowMinutesOfDay(), doha.hour * 60 + doha.minute);
    });

    test('formats minute-of-day as Doha wall clock', () {
      expect(DohaTime.formatMinutesOfDay(0), '12:00 AM');
      expect(DohaTime.formatMinutesOfDay(515), '8:35 AM');
      expect(DohaTime.formatMinutesOfDay(720), '12:00 PM');
      expect(DohaTime.formatMinutesOfDay(12 * 60 + 45), '12:45 PM');
      expect(DohaTime.formatMinutesOfDay(17 * 60 + 29), '5:29 PM');
      expect(DohaTime.formatMinutesOfDay(23 * 60 + 59), '11:59 PM');
    });
  });

  group('ScheduleService', () {
    final service = ScheduleService();

    test('countdown is measured against the Doha clock, not the device clock',
        () {
      final dohaMinutes = DohaTime.nowMinutesOfDay();
      expect(service.getMinutesUntilArrival(dohaMinutes), 0);

      // One hour after the current Doha minute-of-day wraps through midnight.
      expect(service.getMinutesUntilArrival((dohaMinutes + 60) % 1440), 60);
    });

    test('times that already ran today are flagged as tomorrow', () {
      final dohaMinutes = DohaTime.nowMinutesOfDay();
      expect(service.isTomorrow((dohaMinutes + 1) % 1440), isFalse);
      if (dohaMinutes > 0) {
        expect(service.isTomorrow(dohaMinutes - 1), isTrue);
      }
    });

    test('getNextBuses picks up the next Doha-local runs', () {
      final dohaMinutes = DohaTime.nowMinutesOfDay();
      final data = {
        'routes': {
          'female blue': [
            (dohaMinutes + 5) % 1440,
            (dohaMinutes + 20) % 1440,
            (dohaMinutes + 35) % 1440,
          ],
        },
      };

      final next = service.getNextBuses(data);

      expect(next['female blue'], hasLength(3));
      expect(next['female blue']!.first, (dohaMinutes + 5) % 1440);
    });
  });
}
