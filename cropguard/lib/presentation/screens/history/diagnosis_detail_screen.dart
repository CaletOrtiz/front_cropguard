import 'package:flutter/material.dart';
import 'package:cropguard/core/models/diagnosis_record.dart';
import 'package:cropguard/presentation/common/diagnosis_result_view.dart';

class DiagnosisDetailScreen extends StatelessWidget {
  const DiagnosisDetailScreen({super.key, required this.diagnosisId});

  final String diagnosisId;

  @override
  Widget build(BuildContext context) {
    final record = SampleDiagnoses.byId(diagnosisId);

    if (record == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Diagnóstico no encontrado')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Resultado del diagnóstico')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: DiagnosisResultView(
            cropId: record.cropId,
            cropName: record.cropName,
            pathogen: record.pathogen,
            pathogenType: record.pathogenType,
            confidence: record.confidence,
            symptoms: record.symptoms,
            recommendations: record.recommendations,
            date: record.date,
          ),
        ),
      ),
    );
  }
}
