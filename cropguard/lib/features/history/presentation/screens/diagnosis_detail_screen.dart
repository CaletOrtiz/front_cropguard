import 'package:kroppi/core/network/api/api_error_message.dart';
import 'package:flutter/material.dart';
import 'package:kroppi/features/history/domain/entities/diagnosis_record.dart';
import 'package:kroppi/features/history/presentation/widgets/diagnosis_result_view.dart';

class DiagnosisDetailScreen extends StatefulWidget {
  const DiagnosisDetailScreen({
    super.key,
    required this.diagnosisId,
    required this.loadRecord,
  });

  final String diagnosisId;
  final Future<DiagnosisRecord?> Function(String id) loadRecord;

  @override
  State<DiagnosisDetailScreen> createState() => _DiagnosisDetailScreenState();
}

class _DiagnosisDetailScreenState extends State<DiagnosisDetailScreen> {
  late Future<DiagnosisRecord?> _record = widget.loadRecord(widget.diagnosisId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultado del diagnóstico')),
      body: SafeArea(
        child: FutureBuilder<DiagnosisRecord?>(
          future: _record,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(apiErrorMessage(snapshot.error!)),
                    TextButton(
                      onPressed: () => setState(() {
                        _record = widget.loadRecord(widget.diagnosisId);
                      }),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }
            final record = snapshot.data;
            if (record == null) {
              return const Center(child: Text('Diagnóstico no disponible.'));
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: DiagnosisResultView(
                cropId: record.cropId,
                cropName: record.cropName,
                pathogen: record.pathogen,
                pathogenType: record.pathogenType,
                confidence: record.confidence,
                symptoms: record.symptoms,
                recommendations: record.recommendations,
                imageUrl: record.imageUrl,
                date: record.date,
              ),
            );
          },
        ),
      ),
    );
  }
}
