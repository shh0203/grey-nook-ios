// Basic smoke test for Grey Nook
// Full UI tests run on a real device / simulator

import 'package:flutter_test/flutter_test.dart';
import 'package:grey_nook/features/chat/chat_time.dart';

void main() {
  group('ChatTime.dayHeader', () {
    final now = DateTime(2026, 7, 15, 10, 30);
    test('returns 今天 for same calendar day', () {
      expect(ChatTime.dayHeader(DateTime(2026, 7, 15, 8, 0), now), '今天');
    });
    test('returns 昨天 for the previous calendar day', () {
      expect(ChatTime.dayHeader(DateTime(2026, 7, 14, 23, 30), now), '昨天');
    });
  });
}
