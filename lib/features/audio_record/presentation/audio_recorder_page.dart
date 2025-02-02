import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'dart:io';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:supabase_flutter/supabase_flutter.dart';

class AudioRecorderPage extends StatefulWidget {
  @override
  _AudioRecorderPageState createState() => _AudioRecorderPageState();
}

class _AudioRecorderPageState extends State<AudioRecorderPage> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isRecording = false;
  bool _isPaused = false;
  double _decibels = 0.0;
  String? _recordedFilePath;
  Timer? _timer;
  int _elapsedSeconds = 0;
  int _speakerCount = 2;
  String _transcription = '';
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _askSpeakerCount().then((_) => _initRecorder());
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _askSpeakerCount() async {
    final count = await showDialog<int>(
      context: context,
      builder: (context) {
        int tempCount = _speakerCount;
        return AlertDialog(
          title: const Text('대화자 수 설정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('대화자 수를 선택하세요:'),
              StatefulBuilder(
                builder: (context, setState) {
                  return DropdownButton<int>(
                    value: tempCount,
                    items: List.generate(10, (index) => index + 1).map((e) {
                      return DropdownMenuItem<int>(
                        value: e,
                        child: Text('$e명'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        tempCount = value ?? 2;
                      });
                    },
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, tempCount),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );

    if (count != null) {
      setState(() {
        _speakerCount = count;
      });
    }
  }

  Future<void> _initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    await _recorder.openRecorder();
    _recorder.setSubscriptionDuration(const Duration(milliseconds: 200));
    _recorder.onProgress?.listen((event) {
      if (_recorder.isRecording) {
        setState(() {
          _decibels = event.decibels ?? 0.0;
        });
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isRecording && !_isPaused) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  Future<void> _pauseRecording() async {
    await _recorder.pauseRecorder();
    setState(() {
      _isPaused = true;
    });
  }

  Future<void> _resumeRecording() async {
    await _recorder.resumeRecorder();
    setState(() {
      _isPaused = false;
    });
  }

  Future<void> _startListening() async {
    bool available = await _speechToText.initialize();
    if (available) {
      _speechToText.listen(
        onResult: (result) {
          setState(() {
            _transcription += result.recognizedWords + '\n';
          });
        },
        localeId: 'ko-KR',
      );
    }
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
  }

  Future<void> _uploadToSupabase() async {
    try {
      final audioFileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.aac';
      final audioPath = await supabase.storage.from('recordings').upload(audioFileName, File(_recordedFilePath!));
      final transcriptionFileName = 'transcription_${DateTime.now().millisecondsSinceEpoch}.txt';
      final transcriptionFile = File('${Directory.systemTemp.path}/$transcriptionFileName')
        ..writeAsStringSync(_transcription);
      await supabase.storage.from('transcriptions').upload(transcriptionFileName, transcriptionFile);
      print('Uploaded audio: $audioPath');
    } catch (e) {
      print('Error uploading files: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Recorder with Transcription')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording
                        ? Colors.red.withOpacity((_decibels / 120).clamp(0.2, 1.0))
                        : Colors.grey,
                  ),
                ),
                Icon(
                  Icons.mic,
                  size: 80,
                  color: _isRecording ? Colors.white : Colors.grey[400],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _formatTime(_elapsedSeconds),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (_transcription.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '실시간 자막:\n$_transcription',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.fiber_manual_record, color: Colors.red),
                  iconSize: 50,
                  onPressed: (_isRecording || _isPaused) ? null : () async {
                    _recordedFilePath = '${Directory.systemTemp.path}/recording.aac';
                    await _recorder.startRecorder(toFile: _recordedFilePath);
                    await _startListening();
                    setState(() {
                      _isRecording = true;
                      _isPaused = false;
                      _elapsedSeconds = 0;
                    });
                    _startTimer();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.pause, color: _isPaused ? Colors.deepOrange : Colors.orange),
                  iconSize: 50,
                  onPressed: _isRecording && !_isPaused ? _pauseRecording : (_isPaused ? _resumeRecording : null),
                ),
                IconButton(
                  icon: const Icon(Icons.stop, color: Colors.black),
                  iconSize: 50,
                  onPressed: _isRecording || _isPaused ? () async {
                    await _recorder.stopRecorder();
                    await _stopListening();
                    await _uploadToSupabase();
                    setState(() {
                      _isRecording = false;
                      _isPaused = false;
                    });
                    _stopTimer();
                  } : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

}
