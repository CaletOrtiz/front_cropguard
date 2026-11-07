import 'package:flutter/foundation.dart';

/// Aviso compartido de "cambiaron los datos de un lote" (cosechas, pérdidas…).
/// Las pantallas del lote (detalle, estadísticas, historial, listas) lo
/// escuchan y recargan si el cambio es de su lote.
class PlotDataRefreshNotifier extends ChangeNotifier {
  PlotDataRefreshNotifier._();

  static final instance = PlotDataRefreshNotifier._();

  String? _lastPlotId;

  /// Lote del último cambio notificado.
  String? get lastPlotId => _lastPlotId;

  void plotChanged(String plotId) {
    _lastPlotId = plotId;
    notifyListeners();
  }
}
