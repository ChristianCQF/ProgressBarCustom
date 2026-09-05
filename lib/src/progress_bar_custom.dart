import 'package:flutter/material.dart';

enum _ProgressBarMode { load, counter }

/// Un widget de barra de progreso altamente personalizable.
///
/// Utiliza los constructores con nombre para elegir el modo:
/// - [ProgressBarCustom.load]: Para cargas controladas externamente (0% a 100%).
/// - [ProgressBarCustom.counter]: Para animaciones automáticas por tiempo (cuentas regresivas o progresivas).
class ProgressBarCustom extends StatefulWidget {
  final _ProgressBarMode _mode;

  // Propiedades visuales compartidas
  final double height;
  final double borderRadius;
  final Color trackColor;
  final Color indicatorColor;
  final EdgeInsetsGeometry? padding;
  final Alignment? alignment;
  final VoidCallback? onComplete;

  // Propiedades exclusivas de LOAD
  final double? loadValue;
  final Duration loadSmoothDuration;

  // Propiedades exclusivas de COUNTER
  final Duration? counterDuration;
  final bool isReversed;
  final ValueChanged<int>? onTick;

  // ==========================================
  // CONSTRUCTOR: MODO CARGA (LOAD)
  // ==========================================
  /// Para descargas o cargas controladas externamente (siempre de 0.0 a 1.0).
  /// Nota: No es 'const' porque 'value' se evalúa en runtime y usamos .clamp()
  ProgressBarCustom.load({
    super.key,
    required double value,
    Duration smoothDuration = const Duration(milliseconds: 80),
    this.height = 6.0,
    this.borderRadius = 4.0,
    this.trackColor = Colors.grey,
    this.indicatorColor = Colors.green,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.alignment,
    this.onComplete,
  }) : _mode = _ProgressBarMode.load,
       loadValue = value.clamp(0.0, 1.0),
       loadSmoothDuration = smoothDuration,
       counterDuration = null,
       isReversed = false,
       onTick = null;

  // ==========================================
  // CONSTRUCTOR: MODO CONTADOR (COUNTER)
  // ==========================================
  /// Para animaciones automáticas basadas en tiempo (cuenta regresiva o progresiva).
  /// Nota: No es 'const' para permitir el uso de closures en onComplete y onTick.
  const ProgressBarCustom.counter({
    super.key,
    required Duration duration,
    this.isReversed = true,
    this.height = 6.0,
    this.borderRadius = 4.0,
    this.trackColor = Colors.grey,
    this.indicatorColor = Colors.green,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.alignment,
    this.onComplete,
    this.onTick,
  }) : _mode = _ProgressBarMode.counter,
       counterDuration = duration,
       loadValue = null,
       loadSmoothDuration = const Duration(milliseconds: 80);

  @override
  State<ProgressBarCustom> createState() => _ProgressBarCustomState();
}

class _ProgressBarCustomState extends State<ProgressBarCustom>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _lastEmittedPercent = -1;

  // Flag para evitar múltiples disparos de onComplete en modo LOAD
  bool _hasLoadCompleted = false;

  @override
  void initState() {
    super.initState();

    if (widget._mode == _ProgressBarMode.counter) {
      _controller = AnimationController(
        vsync: this,
        duration: widget.counterDuration,
        value: widget.isReversed ? 1.0 : 0.0,
      );
      _setupCounterMode();
    } else {
      _controller = AnimationController(
        vsync: this,
        value: widget.loadValue ?? 0.0,
      );
      _setupLoadMode();
    }
  }

  void _setupCounterMode() {
    void emitTick() {
      if (widget.onTick != null) {
        final percent = (_controller.value * 100).round();
        if (percent != _lastEmittedPercent) {
          _lastEmittedPercent = percent;
          widget.onTick!(percent);
        }
      }
    }

    _controller.addListener(emitTick);
    emitTick();

    _controller.addStatusListener((status) {
      if (!widget.isReversed && status == AnimationStatus.completed) {
        widget.onComplete?.call();
      } else if (widget.isReversed && status == AnimationStatus.dismissed) {
        widget.onComplete?.call();
      }
    });

    if (widget.isReversed) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  void _setupLoadMode() {
    if (widget.loadValue != null &&
        widget.loadValue! >= 1.0 &&
        !_hasLoadCompleted) {
      _hasLoadCompleted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onComplete?.call();
      });
    }
  }

  @override
  void didUpdateWidget(covariant ProgressBarCustom oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget._mode == _ProgressBarMode.counter) {
      if (oldWidget.counterDuration != widget.counterDuration) {
        _controller.duration = widget.counterDuration;
      }
    } else {
      // Lógica exclusiva para modo LOAD
      if (oldWidget.loadValue != widget.loadValue) {
        final newValue = widget.loadValue!;

        _controller.animateTo(
          newValue.clamp(0.0, 1.0),
          duration: widget.loadSmoothDuration,
          curve: Curves.easeOut,
        );

        // Disparar onComplete SOLO la primera vez que cruza 1.0
        if (newValue >= 1.0 && !_hasLoadCompleted) {
          _hasLoadCompleted = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onComplete?.call();
          });
        } else if (newValue < 1.0) {
          // Resetear el flag si la carga se reinicia o cancela
          _hasLoadCompleted = false;
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return _buildBar(_controller.value);
      },
    );
  }

  Widget _buildBar(double currentValue) {
    final progressBar = _ProgressBarRenderer(
      currentValue: currentValue,
      trackColor: widget.trackColor,
      indicatorColor: widget.indicatorColor,
      height: widget.height,
      borderRadius: widget.borderRadius,
      padding: widget.padding,
    );

    return widget.alignment != null
        ? Align(alignment: widget.alignment!, child: progressBar)
        : progressBar;
  }
}

class _ProgressBarRenderer extends StatelessWidget {
  final double currentValue;
  final Color trackColor;
  final Color indicatorColor;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const _ProgressBarRenderer({
    required this.currentValue,
    required this.trackColor,
    required this.indicatorColor,
    required this.height,
    required this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: trackColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: currentValue.clamp(0.0, 1.0),
          child: Container(color: indicatorColor),
        ),
      ),
    );
  }
}
