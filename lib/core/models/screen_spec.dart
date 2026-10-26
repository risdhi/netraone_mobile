import 'package:flutter/material.dart';

class ScreenSpec {
  final String title, resource;
  final IconData icon;
  final bool writable;
  const ScreenSpec(this.title, this.resource, this.icon,
      {this.writable = false});
}

List<ScreenSpec> roleScreens(String role) {
  if (role == 'platform_admin')
    return [
      const ScreenSpec('Perusahaan', 'companies', Icons.business,
          writable: true),
      const ScreenSpec('Lokasi', 'sites', Icons.place, writable: true),
      const ScreenSpec('High Computing', 'edges', Icons.memory, writable: true),
      const ScreenSpec('Kamera', 'cameras', Icons.videocam, writable: true),
      const ScreenSpec('Grup', 'groups', Icons.groups, writable: true),
      const ScreenSpec('Mapping Kamera', 'camera_mappings', Icons.account_tree,
          writable: true),
      const ScreenSpec('Event', 'events', Icons.warning_amber),
      const ScreenSpec('Pengguna', 'users', Icons.people, writable: true),
      const ScreenSpec('Integration Profile', 'integration_profiles',
          Icons.settings_input_component,
          writable: true),
      const ScreenSpec('Notifikasi', 'notifications', Icons.notifications),
    ];
  if (role == 'member_admin')
    return [
      const ScreenSpec('Lokasi', 'sites', Icons.place),
      const ScreenSpec('Kamera', 'cameras', Icons.videocam),
      const ScreenSpec('Event', 'events', Icons.warning_amber),
      const ScreenSpec('Pengguna', 'users', Icons.people, writable: true),
      const ScreenSpec('Grup', 'groups', Icons.groups, writable: true),
      const ScreenSpec('Mapping Kamera', 'camera_mappings', Icons.account_tree,
          writable: true),
      const ScreenSpec('Notifikasi', 'notifications', Icons.notifications),
    ];
  return [
    const ScreenSpec('Kamera Saya', 'cameras', Icons.videocam),
    const ScreenSpec('Event Saya', 'events', Icons.warning_amber),
    const ScreenSpec('Notifikasi', 'notifications', Icons.notifications),
    const ScreenSpec('Profil', 'profile', Icons.person),
  ];
}
