import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_debug_overlay/flutter_debug_overlay.dart';

void main() {
  late DebugOverlayController controller;

  setUp(() {
    controller = DebugOverlayController.instance;
    controller.reset(); // Clean state before each test
  });

  group('DebugOverlayController', () {
    test('should be a singleton', () {
      final instance1 = DebugOverlayController.instance;
      final instance2 = DebugOverlayController.instance;
      expect(instance1, same(instance2));
    });

    test('should start with overlay visible', () {
      expect(controller.isOverlayVisible, isTrue);
    });

    test('should start with bottom sheet hidden', () {
      expect(controller.isBottomSheetVisible, isFalse);
    });

    test('should add logs', () {
      final log = NetworkLog.create(
        method: 'GET',
        endpoint: '/api/users',
        statusCode: 200,
      );

      controller.addLog(log);

      expect(controller.logs, hasLength(1));
      expect(controller.logs.first.endpoint, '/api/users');
    });

    test('should clear logs', () {
      final log = NetworkLog.create(
        method: 'GET',
        endpoint: '/api/users',
        statusCode: 200,
      );

      controller.addLog(log);
      expect(controller.logs, hasLength(1));

      controller.clearLogs();
      expect(controller.logs, isEmpty);
    });

    test('should show/hide bottom sheet', () {
      expect(controller.isBottomSheetVisible, isFalse);

      controller.showBottomSheet();
      expect(controller.isBottomSheetVisible, isTrue);

      controller.hideBottomSheet();
      expect(controller.isBottomSheetVisible, isFalse);
    });

    test('should limit logs to maxLogs', () {
      // Add more than max logs
      for (int i = 0; i < 150; i++) {
        controller.addLog(NetworkLog.create(
          method: 'GET',
          endpoint: '/api/test/$i',
          statusCode: 200,
        ));
      }

      expect(controller.logs.length, DebugOverlayController.maxLogs);
    });

    test('should notify listeners on changes', () {
      var notified = false;
      controller.addListener(() {
        notified = true;
      });

      controller.addLog(NetworkLog.create(
        method: 'GET',
        endpoint: '/api/test',
        statusCode: 200,
      ));

      expect(notified, isTrue);
    });
  });

  group('NetworkLog', () {
    test('should identify success status codes', () {
      final log = NetworkLog.create(
        method: 'GET',
        endpoint: '/test',
        statusCode: 200,
      );
      expect(log.isSuccess, isTrue);
      expect(log.isClientError, isFalse);
      expect(log.isServerError, isFalse);
    });

    test('should identify client error status codes', () {
      final log = NetworkLog.create(
        method: 'GET',
        endpoint: '/test',
        statusCode: 404,
      );
      expect(log.isSuccess, isFalse);
      expect(log.isClientError, isTrue);
      expect(log.isServerError, isFalse);
    });

    test('should identify server error status codes', () {
      final log = NetworkLog.create(
        method: 'GET',
        endpoint: '/test',
        statusCode: 500,
      );
      expect(log.isSuccess, isFalse);
      expect(log.isClientError, isFalse);
      expect(log.isServerError, isTrue);
    });
  });
}


