import 'package:flutter/material.dart';
import '../../../core/shared.dart';
import 'dart:convert';

class ErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback retry;
  const ErrorPanel(this.message, this.retry, {super.key});
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, color: errorColor, size: 40),
            Text(message, textAlign: TextAlign.center),
            TextButton(onPressed: retry, child: const Text('Coba lagi'))
          ])));
}

class ResourceScreen extends StatefulWidget {
  final ScreenSpec spec;
  final bool embedded;
  const ResourceScreen({super.key, required this.spec, this.embedded = false});
  @override
  State<ResourceScreen> createState() => _ResourceState();
}

class _ResourceState extends State<ResourceScreen> {
  List<Map<String, dynamic>> rows = [];
  bool loading = true;
  String? error;
  final search = TextEditingController();
  int pageNumber = 1;
  int pageSize = 25;
  int total = 0;
  int lastPage = 1;
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await api.page(widget.spec.resource,
          search: search.text.trim(), page: pageNumber, perPage: pageSize);
      final items = (result['data'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      if (mounted)
        setState(() {
          rows = items;
          total = (result['total'] as num?)?.toInt() ?? items.length;
          lastPage = (result['last_page'] as num?)?.toInt() ?? 1;
        });
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> openEditor([Map<String, dynamic>? item]) async {
    final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
            builder: (_) =>
                EditorScreen(resource: widget.spec.resource, item: item)));
    if (result == true) reload();
  }

  Future<void> remove(Map<String, dynamic> item) async {
    final yes = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: const Text('Hapus data?'),
                content: Text('Hapus ${v(item['name'] ?? item['id'])}?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Batal')),
                  FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Hapus'))
                ]));
    if (yes != true) return;
    try {
      await api.request('DELETE', '/${widget.spec.resource}/${item['id']}');
      reload();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(children: [
      Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Expanded(
                child: Text(widget.spec.title,
                    style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: navy))),
            if (widget.spec.writable)
              IconButton(
                  onPressed: () => openEditor(),
                  icon: const Icon(Icons.add_circle, color: blue),
                  tooltip: 'Tambah'),
            IconButton(
                onPressed: reload,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh'),
          ])),
      if (widget.spec.resource != 'notifications')
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: TextField(
                controller: search,
                onSubmitted: (_) {
                  pageNumber = 1;
                  reload();
                },
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Cari ${widget.spec.title}',
                    suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          pageNumber = 1;
                          reload();
                        })))),
      const SizedBox(height: 8),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(children: [
            Text('$total data', style: const TextStyle(color: mutedInk)),
            const Spacer(),
            const Text('Baris: '),
            DropdownButton<int>(
                value: pageSize,
                items: [10, 25, 50, 100]
                    .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                    .toList(),
                onChanged: (n) {
                  if (n != null) {
                    pageSize = n;
                    pageNumber = 1;
                    reload();
                  }
                }),
            IconButton(
                onPressed: pageNumber > 1
                    ? () {
                        pageNumber--;
                        reload();
                      }
                    : null,
                icon: const Icon(Icons.chevron_left)),
            Text('$pageNumber/$lastPage'),
            IconButton(
                onPressed: pageNumber < lastPage
                    ? () {
                        pageNumber++;
                        reload();
                      }
                    : null,
                icon: const Icon(Icons.chevron_right)),
          ])),
      Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : error != null
                  ? ErrorPanel(error!, reload)
                  : RefreshIndicator(
                      onRefresh: reload,
                      child: rows.isEmpty
                          ? ListView(children: const [
                              Padding(
                                  padding: EdgeInsets.all(32),
                                  child: Center(child: Text('Belum ada data.')))
                            ])
                          : ListView.builder(
                              itemCount: rows.length,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              itemBuilder: (ctx, i) {
                                final item = rows[i];
                                if (widget.spec.resource == 'events')
                                  return EventTile(event: item);
                                if (widget.spec.resource == 'notifications')
                                  return NotificationTile(
                                      item: item, onRefresh: reload);
                                final title = v(item['name'] ??
                                    item['event_type'] ??
                                    item['serial'] ??
                                    item['camera_name'] ??
                                    item['user_name'] ??
                                    item['group_name'] ??
                                    'Data');
                                final subtitle = [
                                  item['company_name'],
                                  item['site_name'],
                                  if (api.me?['role'] == 'platform_admin')
                                    item['edge_name'],
                                  item['camera_name'],
                                  item['user_name'],
                                  item['group_name'],
                                  item['status'],
                                  item['serial'],
                                  item['email'],
                                  item['device_id'],
                                  item['last_seen_at']
                                ].where((e) => e != null).map(v).join(' · ');
                                return Card(
                                    child: ListTile(
                                  leading: CircleAvatar(
                                      backgroundColor: picotelMint,
                                      child:
                                          Icon(widget.spec.icon, color: blue)),
                                  title: Text(title),
                                  subtitle: Text(
                                      subtitle.isEmpty
                                          ? 'Lihat detail'
                                          : subtitle,
                                      maxLines: 2),
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => DetailScreen(
                                              resource: widget.spec.resource,
                                              title: widget.spec.title,
                                              item: item))),
                                  trailing: widget.spec.writable
                                      ? PopupMenuButton<String>(
                                          onSelected: (choice) {
                                            if (choice == 'edit')
                                              openEditor(item);
                                            if (choice == 'delete')
                                              remove(item);
                                          },
                                          itemBuilder: (_) => [
                                                const PopupMenuItem(
                                                    value: 'edit',
                                                    child: Text('Edit')),
                                                const PopupMenuItem(
                                                    value: 'delete',
                                                    child: Text('Hapus'))
                                              ])
                                      : const Icon(Icons.chevron_right),
                                ));
                              }))),
    ]);
    return widget.embedded
        ? content
        : Scaffold(
            appBar: AppBar(title: Text(widget.spec.title)), body: content);
  }
}

class EventTile extends StatelessWidget {
  final Map<String, dynamic> event;
  const EventTile({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final severity = '${event['severity'] ?? ''}'.toLowerCase();
    final severityColor = switch (severity) {
      'critical' => errorColor,
      'high' => warningColor,
      'medium' => warningColor,
      _ => blue,
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailScreen(
              resource: 'events',
              title: 'Detail Event',
              item: event,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: severityColor,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      v(event['event_type']),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${displayField(event, 'camera_id')} · ${displayField(event, 'occurred_at')}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: mutedInk,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (severity.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    displayField(event, 'severity'),
                    style: TextStyle(
                      color: severityColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 3),
              const Icon(Icons.chevron_right, color: mutedInk, size: 19),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onRefresh;
  const NotificationTile(
      {super.key, required this.item, required this.onRefresh});
  @override
  Widget build(BuildContext context) => Card(
          child: ListTile(
        leading: Semantics(
            label: item['read_at'] == null ? 'Belum dibaca' : 'Sudah dibaca',
            child: Icon(
                item['read_at'] == null
                    ? Icons.notifications_active
                    : Icons.notifications_none,
                color: blue)),
        title: Text(displayField(item, 'event_id')),
        subtitle: Text('Channel: ${v(item['channel'])} · ${v(item['status'])}'),
        trailing: item['read_at'] == null
            ? IconButton(
                icon: const Icon(Icons.done),
                tooltip: 'Tandai dibaca',
                onPressed: () async {
                  try {
                    await api.request(
                        'POST', '/notifications/${item['id']}/read');
                    onRefresh();
                  } catch (e) {
                    if (context.mounted)
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('$e')));
                  }
                })
            : null,
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => DetailScreen(
                    resource: 'notifications',
                    title: 'Detail Notifikasi',
                    item: item))),
      ));
}

class DetailScreen extends StatefulWidget {
  final String resource;
  final String title;
  final Map<String, dynamic> item;

  const DetailScreen({
    super.key,
    required this.resource,
    required this.title,
    required this.item,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<Map<String, dynamic>> detail;

  @override
  void initState() {
    super.initState();
    detail = _load();
  }

  Future<Map<String, dynamic>> _load() async {
    final id = widget.item['id'];
    if (id == null)
      throw ApiError('ID data tidak tersedia untuk membuka detail.');
    final response = await api.detail(widget.resource, id);
    final nested = response['data'];
    return nested is Map ? Map<String, dynamic>.from(nested) : response;
  }

  bool _isSafeField(String key) {
    final normalized = key.toLowerCase();
    if (normalized == 'id' ||
        normalized == 'record_id' ||
        normalized.contains('payload') ||
        normalized.contains('biometric') ||
        normalized.contains('credential') ||
        normalized.contains('password') ||
        normalized.contains('secret') ||
        normalized.contains('token') ||
        normalized.contains('network') ||
        normalized.contains('edge') ||
        normalized.contains('computing') ||
        normalized.endsWith('_url')) {
      return false;
    }

    const fieldsByResource = <String, Set<String>>{
      'events': {
        'event_type',
        'occurred_at',
        'severity',
        'status',
        'camera_id',
        'camera_name',
        'site_name',
        'company_name',
      },
      'cameras': {
        'name',
        'status',
        'device_id',
        'site_name',
        'company_name',
        'ai_functions',
      },
      'notifications': {
        'event_id',
        'channel',
        'status',
        'read_at',
        'created_at',
        'event_type',
        'camera_name',
      },
    };
    final allowed = fieldsByResource[widget.resource];
    return allowed == null
        ? !normalized.endsWith('_name')
        : allowed.contains(key);
  }

  Widget _content(Map<String, dynamic> item) {
    final entries = item.entries
        .where((entry) => entry.value != null && _isSafeField(entry.key))
        .toList();
    if (entries.isEmpty) {
      return const Center(child: Text('Tidak ada detail aman yang tersedia.'));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (widget.resource == 'events')
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Media event tidak ditampilkan di aplikasi.'),
              subtitle: Text(
                'API saat ini belum menyediakan kontrak akses media yang aman.',
              ),
            ),
          ),
        ...entries.map(
          (entry) => Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fieldTitle(entry.key),
                    style: const TextStyle(fontSize: 11, color: mutedInk),
                  ),
                  const SizedBox(height: 3),
                  Text(displayField(item, entry.key)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: FutureBuilder<Map<String, dynamic>>(
          future: detail,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ErrorPanel(
                '${snapshot.error}',
                () => setState(() => detail = _load()),
              );
            }
            return _content(snapshot.data!);
          },
        ),
      );
}

const fields = <String, List<String>>{
  'companies': ['name', 'contact_email', 'status'],
  'sites': ['company_id', 'name', 'address'],
  'edges': [
    'company_id',
    'site_id',
    'integration_profile_id',
    'name',
    'serial',
    'status',
    'network_host',
    'network_port',
    'network_protocol',
    'enabled_events'
  ],
  'cameras': [
    'company_id',
    'edge_id',
    'name',
    'device_id',
    'status',
    'ai_functions'
  ],
  'users': [
    'company_id',
    'name',
    'email',
    'password',
    'role',
    'phone',
    'whatsapp',
    'telegram',
    'notification_channels',
    'active'
  ],
  'groups': ['company_id', 'name'],
  'camera_mappings': [
    'company_id',
    'camera_id',
    'user_id',
    'group_id',
    'channel'
  ],
  'integration_profiles': ['name', 'vendor', 'protocol', 'capabilities'],
};
const refs = <String, String>{
  'company_id': 'companies',
  'site_id': 'sites',
  'edge_id': 'edges',
  'camera_id': 'cameras',
  'user_id': 'users',
  'group_id': 'groups',
  'integration_profile_id': 'integration_profiles',
};

class EditorScreen extends StatefulWidget {
  final String resource;
  final Map<String, dynamic>? item;
  const EditorScreen({super.key, required this.resource, this.item});
  @override
  State<EditorScreen> createState() => _EditorState();
}

class _EditorState extends State<EditorScreen> {
  final form = GlobalKey<FormState>();
  final values = <String, TextEditingController>{};
  bool busy = false;
  String? error;
  @override
  void initState() {
    super.initState();
    for (final field in fields[widget.resource] ?? []) {
      final initial = widget.item?[field];
      values[field] = TextEditingController(
          text: initial == null
              ? ''
              : initial is List || initial is Map
                  ? jsonEncode(initial)
                  : '$initial');
    }
    if (api.me?['role'] != 'platform_admin' &&
        values.containsKey('company_id')) {
      values['company_id']!.text = '${api.me?['company_id']}';
    }
  }

  @override
  void dispose() {
    for (final c in values.values) c.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!(form.currentState?.validate() ?? false)) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final data = <String, dynamic>{};
      for (final entry in values.entries) {
        final f = entry.key, txt = entry.value.text.trim();
        if (f == 'password' && widget.item != null) continue;
        if (txt.isEmpty) {
          data[f] = ['notification_channels', 'enabled_events', 'ai_functions']
                  .contains(f)
              ? <String>[]
              : null;
          continue;
        }
        if (refs.containsKey(f))
          data[f] = int.parse(txt);
        else if (f == 'active')
          data[f] = ['true', '1', 'yes'].contains(txt.toLowerCase());
        else if (f == 'network_port')
          data[f] = int.parse(txt);
        else if ([
          'ai_functions',
          'capabilities',
          'notification_channels',
          'enabled_events'
        ].contains(f))
          data[f] = jsonDecode(txt);
        else
          data[f] = txt;
      }
      final id = widget.item?['id'];
      await api.request(id == null ? 'POST' : 'PUT',
          '/${widget.resource}${id == null ? '' : '/$id'}', data);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: Text(
                '${widget.item == null ? 'Tambah' : 'Edit'} ${widget.resource}')),
        body: Form(
            key: form,
            child: ListView(padding: const EdgeInsets.all(16), children: [
              ...values.entries.map((entry) {
                final f = entry.key, c = entry.value;
                final isRef = refs.containsKey(f);
                if (f == 'company_id' && api.me?['role'] != 'platform_admin')
                  return const SizedBox.shrink();
                if (f == 'role' && api.me?['role'] != 'platform_admin')
                  return const SizedBox.shrink();
                if (f == 'password' && widget.item != null)
                  return const SizedBox.shrink();
                if (f == 'status' || f == 'role' || f == 'active') {
                  final choices = f == 'status'
                      ? (widget.resource == 'companies'
                          ? ['active', 'inactive', 'suspended']
                          : ['online', 'offline', 'maintenance'])
                      : f == 'role'
                          ? ['platform_admin', 'member_admin', 'member_user']
                          : ['true', 'false'];
                  return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DropdownButtonFormField<String>(
                        initialValue: choices.contains(c.text) ? c.text : null,
                        decoration: InputDecoration(labelText: fieldTitle(f)),
                        items: choices
                            .map((choice) => DropdownMenuItem(
                                value: choice, child: Text(choice)))
                            .toList(),
                        onChanged: (choice) => c.text = choice ?? '',
                      ));
                }
                if (['notification_channels', 'enabled_events', 'ai_functions']
                    .contains(f)) {
                  final all = f == 'notification_channels'
                      ? ['push', 'whatsapp', 'telegram', 'email']
                      : [
                          'Intrusion',
                          'Line Crossing',
                          'People Counting',
                          'Loitering',
                          'Phone Usage',
                          'Sleep Detection'
                        ];
                  return FormField<List<String>>(
                      initialValue: () {
                        try {
                          return List<String>.from(jsonDecode(c.text) as List);
                        } catch (_) {
                          return <String>[];
                        }
                      }(),
                      builder: (state) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(fieldTitle(f),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                ...all.map((choice) => CheckboxListTile(
                                    dense: true,
                                    title: Text(choice),
                                    value:
                                        state.value?.contains(choice) ?? false,
                                    onChanged: (checked) {
                                      final selected = [...?state.value];
                                      if (checked == true) {
                                        selected.add(choice);
                                      } else {
                                        selected.remove(choice);
                                      }
                                      state.didChange(selected);
                                      c.text = jsonEncode(selected);
                                    })),
                              ]));
                }
                return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                        controller: c,
                        maxLines: [
                          'ai_functions',
                          'capabilities',
                          'credentials',
                          'address'
                        ].contains(f)
                            ? 3
                            : 1,
                        obscureText: f == 'password',
                        decoration: InputDecoration(
                            labelText: f.replaceAll('_', ' '),
                            helperText: ['ai_functions', 'capabilities']
                                    .contains(f)
                                ? 'JSON valid; contoh [] atau {}'
                                : isRef
                                    ? 'Masukkan ID relasi yang diberikan server'
                                    : null),
                        validator: (x) {
                          if (f == 'name' && (x == null || x.trim().isEmpty))
                            return 'Nama wajib diisi';
                          if (refs.containsKey(f) &&
                              x != null &&
                              x.isNotEmpty &&
                              int.tryParse(x) == null) return 'ID harus angka';
                          return null;
                        }));
              }),
              if (error != null)
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(error!,
                        style: const TextStyle(color: errorColor))),
              FilledButton(
                  onPressed: busy ? null : save,
                  child: Text(busy ? 'Menyimpan...' : 'Simpan')),
            ])),
      );
}
