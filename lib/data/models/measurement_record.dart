import 'dart:convert';

class MeasurementRecord {
  final String id;
  final String imagePath;
  final String? patientFirstName;
  final String? patientLastName;
  final String createdAt;
  final Map<String, dynamic> stateJson;

  MeasurementRecord({
    required this.id,
    required this.imagePath,
    this.patientFirstName,
    this.patientLastName,
    required this.createdAt,
    required this.stateJson,
  });

  String get patientFullName {
    final parts = [patientFirstName, patientLastName]
        .where((p) => p != null && p.isNotEmpty)
        .toList();
    return parts.isEmpty ? '' : parts.join(' ');
  }

  double? get pantoscopicAngle {
    final v = stateJson['pantoscopicAngle'];
    if (v == null) return null;
    return (v as num).toDouble();
  }

  Map<String, dynamic> get results {
    return (stateJson['results'] as Map<String, dynamic>?) ?? {};
  }

  String get formattedDate {
    final dt = DateTime.tryParse(createdAt);
    if (dt == null) return createdAt;
    final d = dt.toLocal();
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    final mon = d.month.toString().padLeft(2, '0');
    final year = d.year;
    return '$h:$m  $day/$mon/$year';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'imagePath': imagePath,
    'patientFirstName': patientFirstName,
    'patientLastName': patientLastName,
    'createdAt': createdAt,
    'stateJsonString': jsonEncode(stateJson),
  };

  factory MeasurementRecord.fromJson(Map<String, dynamic> json) {
    final stateStr = json['stateJsonString'] as String? ?? '{}';
    Map<String, dynamic> state;
    try {
      final decoded = jsonDecode(stateStr);
      state = {};
      (decoded as Map).forEach((k, v) => state[k.toString()] = v);
    } catch (_) {
      state = {};
    }
    return MeasurementRecord(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      patientFirstName: json['patientFirstName'] as String?,
      patientLastName: json['patientLastName'] as String?,
      createdAt: json['createdAt'] as String,
      stateJson: state,
    );
  }
}
