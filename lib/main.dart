import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const MaterialApp(home: MicPage()));

class MicPage extends StatefulWidget {
  const MicPage({super.key});
  @override
  State<MicPage> createState() => _MicPageState();
}

class _MicPageState extends State<MicPage> {
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();
  bool _grabando = false;
  String? _ruta;

  Future<void> _iniciar() async {
    final estado = await Permission.microphone.request();
    if (estado.isPermanentlyDenied) {
      await openAppSettings(); // el usuario debe habilitarlo manualmente
      return;
    }
    if (!estado.isGranted) return;

    final dir = await getTemporaryDirectory();
    final ruta =
        '${dir.path}/nota_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(), path: ruta);
    setState(() => _grabando = true);
  }

  Future<void> _detener() async {
    final ruta = await _recorder.stop();
    setState(() {
      _grabando = false;
      _ruta = ruta;
    });
  }

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Micrófono en Flutter')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _grabando ? Icons.mic : Icons.mic_none,
              size: 96,
              color: _grabando ? Colors.red : Colors.grey,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _grabando ? _detener : _iniciar,
              child: Text(_grabando ? 'Detener' : 'Grabar'),
            ),
            if (_ruta != null)
              TextButton(
                onPressed: () => _player.play(DeviceFileSource(_ruta!)),
                child: const Text('Reproducir grabación'),
              ),
          ],
        ),
      ),
    );
  }
}
