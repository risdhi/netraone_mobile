import 'dart:convert';

String v(dynamic x) => x == null
    ? 'â€”'
    : x is List
        ? x.join(', ')
        : x is Map
            ? jsonEncode(x)
            : '$x';
String fieldTitle(String field) {
  const labels = <String, String>{
    'company_id': 'Perusahaan',
    'site_id': 'Lokasi',
    'edge_id': 'High Computing',
    'camera_id': 'Kamera',
    'user_id': 'Pengguna',
    'group_id': 'Grup',
    'integration_profile_id': 'Profil Integrasi',
    'event_id': 'Event',
    'occurred_at': 'Waktu Kejadian',
    'event_type': 'Jenis Event',
    'photo_url': 'Foto Evidence',
    'alarm_video_url': 'Video Alarm',
    'severity': 'Tingkat Keparahan',
  };
  return labels[field] ?? field.replaceAll('_', ' ').toUpperCase();
}

String displayField(Map<String, dynamic> item, String field) {
  if (field.endsWith('_id')) {
    final label = item['${field.substring(0, field.length - 3)}_name'];
    return label == null || '$label'.isEmpty
        ? 'Referensi tidak tersedia'
        : '$label';
  }
  if (field == 'occurred_at' ||
      field == 'created_at' ||
      field == 'updated_at') {
    final parsed = DateTime.tryParse('${item[field]}');
    if (parsed != null) {
      final d = parsed.toLocal();
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    }
  }
  if (field == 'severity') {
    return switch ('${item[field]}'.toLowerCase()) {
      'low' => 'Rendah',
      'medium' => 'Sedang',
      'high' => 'Tinggi',
      'critical' => 'Kritis',
      _ => v(item[field])
    };
  }
  return v(item[field]);
}

String roleName(String? r) => switch (r) {
      'platform_admin' => 'Admin Pengelola',
      'member_admin' => 'Admin Member',
      _ => 'User Member'
    };
