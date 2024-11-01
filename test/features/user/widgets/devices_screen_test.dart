import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:telware_cross_platform/features/user/model/model.dart';
import 'package:telware_cross_platform/features/user/view_model/devices_view_model.dart';

class MockDevicesViewModel extends StateNotifier<AsyncValue<List<Session>>> {
  MockDevicesViewModel() : super(const AsyncValue.loading());

  void setData(List<Session> sessions) {
    state = AsyncValue.data(sessions);
  }

  void fetchSessions() {
    // Simulate successful data fetch after a delay
    Future.delayed(Duration(seconds: 1), () {
      state = AsyncValue.data([
        Session(title: 'Session 1', options: [], trailing: ''),
        Session(title: 'Session 2', options: [], trailing: ''),
      ]);
    });
  }

  void setError(Object error,StackTrace stackTrace) {
    state = AsyncValue.error(error,stackTrace);
  }
}
void main() {
  group('DevicesViewModel Tests', () {
    late ProviderContainer container;


    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('fetchSessions should load sessions successfully', () async {
      final viewModel = container.read(devicesViewModelProvider.notifier);
      final context = MockBuildContext();
      await viewModel.fetchSessions(context);
      final state = container.read(devicesViewModelProvider);
      expect(state, isA<AsyncValue<List<Session>>>());
      expect(state.value?.length, greaterThan(0));
    });

  });
}

class MockBuildContext extends Mock implements BuildContext {}
