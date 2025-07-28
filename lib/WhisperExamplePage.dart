import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:whisper_flutter_new/whisper_flutter_new.dart';

class WhisperExamplePage extends StatefulWidget {
  const WhisperExamplePage({super.key});
  @override
  State<WhisperExamplePage> createState() => _WhisperExamplePageState();
}

class _WhisperExamplePageState extends State<WhisperExamplePage> {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String _transcription = 'Press record to start';

  late Whisper _whisper;

  @override
  void initState() {
    super.initState();
    _whisper = Whisper(
      model: WhisperModel.tiny, // tiny/base/small 등 선택 가능
      downloadHost: 'https://huggingface.co/ggerganov/whisper.cpp/resolve/main',
    );
  }

  Future<void> _recordToggle() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() => _isRecording = false);

      if (path != null) {
        _transcribe(path);
      }
    } else {
      if (await _recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/meeting.wav';
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav, // ✅ WAV 인코더
            sampleRate: 16000, // ✅ Whisper 요구값
            bitRate: 128000,
          ),
          path: filePath,
        );
        setState(() => _isRecording = true);
      }
    }
  }

  Future<void> _transcribe(String audioPath) async {
    setState(() => _transcription = 'Transcribing...');
    try {
      final result = await _whisper.transcribe(
        transcribeRequest: TranscribeRequest(
          audio: audioPath,
          isTranslate: false,
          isNoTimestamps: true,
          splitOnWord: false,
        ),
      );

      final text = result.text; // ✅ 여기서 String 추출

      setState(() {
        _transcription = text ?? 'No text recognized';
      });
    } catch (e) {
      setState(() => _transcription = 'Error: $e');
    }
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Whisper Transcription')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(_transcription, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _recordToggle,
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
          ],
        ),
      ),
    );
  }
}
