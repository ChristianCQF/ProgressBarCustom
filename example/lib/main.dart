import 'package:flutter/material.dart';
import 'package:progress_bar_custom/progress_bar_custom.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Progress Bar Demo - Integrado',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.purple),
      home: const IntegratedExampleScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class IntegratedExampleScreen extends StatefulWidget {
  const IntegratedExampleScreen({super.key});

  @override
  State<IntegratedExampleScreen> createState() =>
      _IntegratedExampleScreenState();
}

class _IntegratedExampleScreenState extends State<IntegratedExampleScreen> {
  // ============================================
  // VARIABLES DE CUENTA REGRESIVA (ROJO)
  // ============================================
  String _countdownText = '30 s';
  bool _isCountdownRunning = false;
  int _lastUpdatedCountdownSecond = 30;
  Key? _countdownKey;

  // ============================================
  // VARIABLES DE DESCARGA (AZUL/ÍNDIGO)
  // ============================================
  double _downloadProgress = 0.0;
  String _downloadStatusText = 'Archivo listo para descargar';
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _countdownKey = UniqueKey();
  }

  // ============================================
  // MÉTODO: INICIAR CUENTA REGRESIVA
  // ============================================
  void _startCountdown() {
    setState(() {
      _isCountdownRunning = true;
      _countdownText = '30 s';
      _lastUpdatedCountdownSecond = 30;
      _countdownKey =
          UniqueKey(); // Fuerza la recreación del widget para reiniciar
    });
  }

  // ============================================
  // MÉTODO: INICIAR DESCARGA
  // ============================================
  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _downloadStatusText = 'Conectando con el servidor...';
    });

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    for (int i = 1; i <= 100; i++) {
      if (!_isDownloading) break;

      final delay = Duration(milliseconds: 30 + (i % 4) * 20);
      await Future.delayed(delay);

      if (mounted) {
        setState(() {
          _downloadProgress = i / 100;
          _downloadStatusText = i >= 100
              ? 'Finalizando...'
              : 'Descargando archivo...';
        });
      }
    }

    if (_isDownloading && mounted) {
      setState(() {
        _isDownloading = false;
        _downloadStatusText = '¡Descarga completada con éxito!';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Archivo guardado correctamente'),
            ],
          ),
          backgroundColor: Colors.indigo,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================
  // MÉTODO: CANCELAR DESCARGA
  // ============================================
  void _cancelDownload() {
    setState(() {
      _isDownloading = false;
      _downloadProgress =
          0.0; // Al bajar de 1.0, el flag interno se resetea automáticamente
      _downloadStatusText = 'Descarga cancelada';
    });
  }

  @override
  Widget build(BuildContext context) {
    final int downloadPercent = (_downloadProgress * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Bar - Demo Integrado'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // ============================================
            // SECCIÓN 1: CUENTA REGRESIVA (MODO COUNTER)
            // ============================================
            _buildSectionCard(
              color: Colors.redAccent,
              icon: Icons.timer_outlined,
              title: 'Cuenta Regresiva',
              subtitle: 'De 100% a 0% en 30 segundos',
              child: Column(
                children: [
                  Text(
                    _countdownText,
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      color: Colors.redAccent.shade700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // ✅ ACTUALIZADO: Uso del constructor .counter
                    child: _isCountdownRunning
                        ? ProgressBarCustom.counter(
                            key: _countdownKey,
                            duration: const Duration(seconds: 30),
                            isReversed: true,
                            height: 14.0,
                            borderRadius: 10.0,
                            trackColor: Colors.red.shade100,
                            indicatorColor: Colors.redAccent,
                            onTick: (percent) {
                              final int secondsLeft = (percent * 30 / 100)
                                  .round();

                              if (secondsLeft != _lastUpdatedCountdownSecond &&
                                  mounted) {
                                _lastUpdatedCountdownSecond = secondsLeft;
                                setState(() {
                                  _countdownText = '$secondsLeft s';
                                });
                              }
                            },
                            onComplete: () {
                              debugPrint('¡Cuenta regresiva finalizada!');
                              if (mounted) {
                                setState(() => _isCountdownRunning = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('¡Tiempo agotado!'),
                                    backgroundColor: Colors.redAccent,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                          )
                        : const Center(
                            child: Text(
                              'Listo para iniciar',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isCountdownRunning
                            ? Colors.grey
                            : Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isCountdownRunning ? null : _startCountdown,
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      label: Text(
                        _isCountdownRunning
                            ? 'Cuenta en progreso...'
                            : 'Iniciar Cuenta Regresiva (30s)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ============================================
            // SECCIÓN 2: DESCARGA DE ARCHIVO (MODO LOAD)
            // ============================================
            _buildSectionCard(
              color: Colors.indigo,
              icon: Icons.file_download_outlined,
              title: 'Descarga de Archivo',
              subtitle: 'Simulación de descarga real (0% a 100%)',
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _downloadProgress == 1.0
                              ? Icons.check_circle
                              : Icons.file_present_outlined,
                          size: 40,
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'documento.pdf',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _downloadStatusText,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ ACTUALIZADO: Uso del constructor .load
                        ProgressBarCustom.load(
                          value: _downloadProgress,
                          smoothDuration: const Duration(milliseconds: 80),
                          height: 12.0,
                          borderRadius: 8.0,
                          trackColor: Colors.indigo.shade100,
                          indicatorColor: Colors.indigo,
                          onComplete: () {
                            debugPrint(
                              'Descarga completada al 100% (Solo 1 vez)',
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '$downloadPercent%',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.indigo.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isDownloading
                            ? Colors.redAccent
                            : Colors.indigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isDownloading
                          ? _cancelDownload
                          : (_downloadProgress == 1.0 ? null : _startDownload),
                      icon: Icon(
                        _isDownloading ? Icons.cancel_outlined : Icons.download,
                        color: Colors.white,
                      ),
                      label: Text(
                        _isDownloading
                            ? 'Cancelar Descarga'
                            : (_downloadProgress == 1.0
                                  ? 'Descargado'
                                  : 'Iniciar Descarga (24 MB)'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ============================================
            // LEYENDA INFORMATIVA (ACTUALIZADA)
            // ============================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ℹ️ Modos de uso:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildLegendItem(
                    color: Colors.redAccent,
                    text: 'ProgressBarCustom.counter: Animación automática por tiempo (onTick, onComplete)',
                  ),
                  const SizedBox(height: 6),
                  _buildLegendItem(
                    color: Colors.indigo,
                    text: 'ProgressBarCustom.load: Controlado externamente con value (0.0 a 1.0)',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // WIDGET AUXILIAR: TARJETA DE SECCIÓN
  // ============================================
  Widget _buildSectionCard({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  // ============================================
  // WIDGET AUXILIAR: ITEM DE LEYENDA
  // ============================================
  Widget _buildLegendItem({required Color color, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
