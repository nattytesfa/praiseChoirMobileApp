import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _audioRecorder = AudioRecorder();

  Future<bool> startRecording(String filePath) async {
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: filePath,
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<String?> stopRecording() async {
    try {
      return await _audioRecorder.stop();
    } catch (e) {
      return null;
    }
  }

  Future<void> playAudio(String filePath) async {
    try {
      await _audioPlayer.setFilePath(filePath);
      await _audioPlayer.play();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
  }

  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;

  void dispose() {
    _audioPlayer.dispose();
    _audioRecorder.dispose();
  }
}
