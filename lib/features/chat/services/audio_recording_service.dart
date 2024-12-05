// audio_recorder.dart
import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telware_cross_platform/core/utils.dart';

class AudioRecorderService {
  // TODO: This works only on mobile if you tried to run it on web it will throw an error
  final RecorderController _recorderController;
  String? musicFile;
  bool isRecording = false;
  bool isRecordingCompleted = false;
  bool isRecordingLocked = false;
  bool isRecordingPaused = false;
  double lockRecordingDragPosition = 0;
  final lockPath = "assets/json/passcode_lock.json";
  String? recordingPath;
  late Directory appDirectory;

  final Function updateUI; // Function to update the chat screen

  // Constructor to receive setState
  AudioRecorderService({required this.updateUI})
      : _recorderController = RecorderController()
          ..androidEncoder = AndroidEncoder.aac
          ..androidOutputFormat = AndroidOutputFormat.aac_adts
          ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
          ..bitRate = 128000
          ..sampleRate = 44100;

  void dispose() {
    _recorderController.dispose();
  }

  int getDuration() {
    if (recordingPath == null) return 0;
    return _recorderController.recordedDuration.inSeconds;
  }

  void getDir() async {
    appDirectory = await getApplicationDocumentsDirectory();
    recordingPath = "${appDirectory.path}/recording.m4a";
    updateUI(() {});
  }

  void _record() async {
    try {
      await _recorderController
          .record(); // This will save the recording with a name of the current date and time
      debugPrint("Recording started");
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (!isRecording) {
        updateUI(() {
          isRecording = true;
        });
      }
    }
  }

  //wait for sending will not set the isRecording to false and you will have to set it manually
  // or call cancel recording to reset every thing
  Future<String?> stopRecording({bool waitForSending = false}) async {
    try {
      recordingPath = await _recorderController.stop(false);
      _recorderController.reset(); // TODO: Check if this is necessary

      if (recordingPath != null) {
        if (waitForSending) return recordingPath;
        isRecordingCompleted = true;
        isRecording = false;
        isRecordingPaused = false;
        updateUI(() {});
        debugPrint(recordingPath);
        debugPrint("Recorded file size: ${File(recordingPath!).lengthSync()}");
        return recordingPath!;
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
    return null;
  }

  void startRecording(BuildContext context) async {
    if (isRecording) return;

    if (isRecordingCompleted) {
      updateUI(() {
        isRecordingCompleted = false;
      });
    }

    var status = await Permission.microphone.status;
    if (status.isGranted) {
      _record();
      vibrate();
    } else if (status.isDenied || status.isRestricted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) {
        // Handle denied permission scenario gracefully
        showSnackBarMessage(
            context, 'Microphone permission is required to record audio.');
      }
    } else if (status.isPermanentlyDenied) {
      // If permanently denied, open app settings
      SnackBarAction action = SnackBarAction(
        label: 'Open Settings',
        onPressed: () => openAppSettings(),
      );
      showSnackBarMessage(context,
          'Microphone permission is permanently denied. Please enable it in settings.',
          action: action);
    }
  }

  void startOrStopRecording(BuildContext context) async {
    try {
      if (isRecording) {
        stopRecording();
      } else {
        startRecording(context);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void pauseRecording() async {
    if (isRecordingPaused) {
      _recorderController.record(path: recordingPath);
    } else {
      _recorderController.pause();
    }
    debugPrint("Recording paused");
    isRecordingPaused = !isRecordingPaused;
    updateUI(() {});
  }

  String? resetRecording() {
    String? tempPath = recordingPath;
    isRecording = false;
    isRecordingLocked = false;
    isRecordingPaused = false;
    isRecordingCompleted = false;
    recordingPath = null;
    updateUI(() {});
    return tempPath;
  }

  void deleteRecording() {
    if (recordingPath == null) {
      debugPrint("No recording to delete");
      return;
    }
    if (File(recordingPath!).existsSync()) {
      File(recordingPath!).deleteSync();
      debugPrint("Recording deleted at $recordingPath");
      resetRecording();
    }
  }

  void cancelRecording() async {
    if (isRecording) {
      String? path = await _recorderController.stop(true);
      if (path != null) {
        if (File(path).existsSync()) {
          File(path).deleteSync();
          debugPrint("Recording deleted at $path");
        }
        debugPrint("Recording canceled");
      }
      resetRecording();
    }
  }

  void lockRecording() {
    if (!isRecordingLocked) vibrate();
    isRecordingLocked = true;
    updateUI(() {});
  }

  void lockRecordingDragPositionUpdate(double dragPosition) {
    if (isRecordingLocked) {
      lockRecordingDragPosition = 0;
      return;
    }
    if (dragPosition < 0) {
      lockRecordingDragPosition = dragPosition;
    }
    updateUI(() {});
  }
}
