import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/hotline_controller.dart';
import '../models/hotline_item_model.dart';
import '../style/style.dart';

class HotlinePage extends StatefulWidget {
  final bool isCounsellor;

  const HotlinePage({
    super.key,
    required this.isCounsellor,
  });

  @override
  State<HotlinePage> createState() => _HotlinePageState();
}

class _HotlinePageState extends State<HotlinePage> {
  final HotlineController hotlineController = HotlineController();

  @override
  void initState() {
    super.initState();
    if (widget.isCounsellor) {
      hotlineController.ensureDefaults();
    }
  }

  String _sanitizePhone(String raw) {
    return raw.replaceAll(RegExp(r'[^0-9+]'), '');
  }

  Future<void> _callNumber(BuildContext context, String number) async {
    final phone = _sanitizePhone(number);
    final uri = Uri(scheme: 'tel', path: phone);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open dialer.')),
      );
    }
  }

  Future<void> _showHotlineActions(
    BuildContext context,
    HotlineItem item,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(item.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(item.number),
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.call_outlined),
                title: const Text('Call now'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _callNumber(context, item.number);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy_outlined),
                title: const Text('Copy number'),
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: item.number));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${item.number} copied')),
                    );
                  }
                  if (sheetContext.mounted) {
                    Navigator.pop(sheetContext);
                  }
                },
              ),
              if (widget.isCounsellor)
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit hotline'),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _showEditDialog(item);
                  },
                ),
              if (widget.isCounsellor)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Delete hotline'),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _confirmDeleteHotline(item);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteHotline(HotlineItem item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Hotline'),
          content: Text('Delete ${item.label}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await hotlineController.deleteHotline(item: item);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hotline deleted.')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  IconData _iconFromKey(String key) {
    switch (key) {
      case 'police':
        return Icons.local_police_outlined;
      case 'hospital':
        return Icons.local_hospital_outlined;
      case 'security':
        return Icons.security_outlined;
      case 'people':
        return Icons.people_outline;
      default:
        return Icons.support_agent_outlined;
    }
  }

  Future<void> _showAddDialog() async {
    final labelController = TextEditingController();
    final numberController = TextEditingController();
    String selectedIcon = 'support';

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Hotline'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                decoration: const InputDecoration(labelText: 'Label'),
              ),
              TextField(
                controller: numberController,
                decoration: const InputDecoration(labelText: 'Number'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedIcon,
                items: const [
                  DropdownMenuItem(value: 'support', child: Text('Support')),
                  DropdownMenuItem(value: 'police', child: Text('Police')),
                  DropdownMenuItem(value: 'hospital', child: Text('Hospital')),
                  DropdownMenuItem(value: 'security', child: Text('Security')),
                  DropdownMenuItem(value: 'people', child: Text('People')),
                ],
                onChanged: (value) {
                  selectedIcon = value ?? 'support';
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await hotlineController.addHotline(
                    label: labelController.text,
                    number: numberController.text,
                    iconKey: selectedIcon,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (!mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog(HotlineItem item) async {
    final labelController = TextEditingController(text: item.label);
    final numberController = TextEditingController(text: item.number);
    String selectedIcon = item.iconKey;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Hotline'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                decoration: const InputDecoration(labelText: 'Label'),
              ),
              TextField(
                controller: numberController,
                decoration: const InputDecoration(labelText: 'Number'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedIcon,
                items: const [
                  DropdownMenuItem(value: 'support', child: Text('Support')),
                  DropdownMenuItem(value: 'police', child: Text('Police')),
                  DropdownMenuItem(value: 'hospital', child: Text('Hospital')),
                  DropdownMenuItem(value: 'security', child: Text('Security')),
                  DropdownMenuItem(value: 'people', child: Text('People')),
                ],
                onChanged: (value) {
                  selectedIcon = value ?? 'support';
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await hotlineController.updateHotline(
                    item: item,
                    label: labelController.text,
                    number: numberController.text,
                    iconKey: selectedIcon,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (!mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: Text('Emergency Hotlines', style: CustomStyle.h3),
              ),
              if (widget.isCounsellor)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Add hotline',
                  onPressed: _showAddDialog,
                ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<HotlineItem>>(
            stream: hotlineController.watchHotlines(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Failed to load hotlines: ${snapshot.error}'),
                );
              }

              final hotlines = snapshot.data ?? <HotlineItem>[];
              if (hotlines.isEmpty) {
                return const Center(child: Text('No hotlines found.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                itemCount: hotlines.length,
                itemBuilder: (context, index) {
                  final item = hotlines[index];
                  return _HotlineTile(
                    label: item.label,
                    number: item.number,
                    icon: _iconFromKey(item.iconKey),
                    onTap: () => _showHotlineActions(context, item),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HotlineTile extends StatelessWidget {
  final String label;
  final String number;
  final IconData icon;
  final VoidCallback onTap;

  const _HotlineTile({
    required this.label,
    required this.number,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color.fromARGB(255, 75, 87, 226)),
        title: Text(label),
        subtitle: Text(number, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.more_horiz),
      ),
    );
  }
}
