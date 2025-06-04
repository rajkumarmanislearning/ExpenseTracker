import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../services/backup_restore_service.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  final BackupRestoreService _service = BackupRestoreService();
  bool _loading = false;
  String? _message;
  String? _backupFilePath;

  Future<void> _backup() async {
    setState(() { _loading = true; _message = null; _backupFilePath = null; });
    try {
      String? savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Select location to save backup Excel file',
        fileName: 'finance_backup_${DateTime.now().millisecondsSinceEpoch}.xlsx',
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );
      if (savePath == null) {
        setState(() { _loading = false; _message = 'Backup cancelled.'; });
        return;
      }
      await _service.backupToExcelCustomPath(savePath);
      setState(() {
        _backupFilePath = savePath;
        _message = '';
      });
    } catch (e) {
      setState(() { _message = 'Backup failed: $e'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  Future<void> _restore() async {
    setState(() { _loading = true; _message = null; });
    try {
      await _service.restoreFromExcel();
      setState(() { _message = 'Restore completed.'; });
    } catch (e) {
      setState(() { _message = 'Restore failed: $e'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.backup),
                label: const Text('Backup to Excel'),
                onPressed: _loading ? null : _backup,
                style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.restore),
                label: const Text('Restore from Excel'),
                onPressed: _loading ? null : _restore,
                style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
              ),
              if (_loading) ...[
                const SizedBox(height: 32),
                const CircularProgressIndicator(),
              ],
              if (_message != null) ...[
                const SizedBox(height: 32),
                Text(_message!, style: const TextStyle(fontSize: 16)),
                if (_backupFilePath != null) ...[
                  const SizedBox(height: 12),
                  SelectableText(_backupFilePath!, style: const TextStyle(fontSize: 14, color: Colors.blueGrey)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Path'),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: _backupFilePath!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Backup file path copied to clipboard')),
                      );
                    },
                  ),
                ]
                else ...[
                  Text(_message!, style: const TextStyle(fontSize: 16)),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
