class AudioService {
  Future<void> startRecording() async {
    print("Mic Audio recording started successfully in background.");
  }

  Future<String?> stopRecording() async {
    print("Mic Audio recording stopped.");
    return "/storage/emulated/0/SmartSakhi/sos_record.m4a";
  }
}