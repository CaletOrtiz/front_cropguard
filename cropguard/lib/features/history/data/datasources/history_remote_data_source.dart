import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/diagnosis_record_model.dart';

class HistoryRemoteDataSource {
  const HistoryRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const _select = '''
  id, image_url, created_at, ai_prediction, predicted_label, confidence,
  recommendations, plot_id,
  crop_type:crop_types ( id, name, slug )''';

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw const AuthException('Tu sesión expiró. Inicia sesión de nuevo.');
    }
    return id;
  }

  /// Lista de diagnósticos del usuario, del más reciente al más antiguo.
  Future<List<DiagnosisRecordModel>> getHistory({
    int from = 0,
    int pageSize = 20,
  }) async {
    final rows = await _client
        .from('diagnostics')
        .select(_select)
        .eq('user_id', _userId)
        .order('created_at', ascending: false)
        .range(from, from + pageSize - 1);

    return rows.map(DiagnosisRecordModel.fromJson).toList();
  }

  /// Un diagnóstico por id, o null si no existe o no es del usuario.
  Future<DiagnosisRecordModel?> getById(String id) async {
    final row = await _client
        .from('diagnostics')
        .select(_select)
        .eq('id', id)
        .eq('user_id', _userId)
        .maybeSingle();

    return row == null ? null : DiagnosisRecordModel.fromJson(row);
  }
}
