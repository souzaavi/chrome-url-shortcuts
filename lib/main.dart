import 'package:flutter/material.dart';
import 'dart:js_util' as js_util;
import 'dart:js' as js;
import 'models/shortcut.dart';
import 'services/storage_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'URL Shortcuts',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SizedBox(
        width: 400,
        height: 600,
        child: ShortcutsPage(),
      ),
    );
  }
}

class ShortcutsPage extends StatefulWidget {
  const ShortcutsPage({super.key});

  @override
  State<ShortcutsPage> createState() => _ShortcutsPageState();
}

class _ShortcutsPageState extends State<ShortcutsPage> {
  final StorageService _storage = StorageService();
  final TextEditingController _searchController = TextEditingController();
  List<Shortcut> shortcuts = [];
  List<Shortcut> filteredShortcuts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadShortcuts();
    _setupStorageListener();
  }

  void _setupStorageListener() {
    final callback = js.allowInterop((_) => _loadShortcuts());
    js_util.callMethod(
      js.context['window'],
      'addEventListener',
      ['storage-changed', callback]
    );
  }

  Future<void> _loadShortcuts() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final loadedShortcuts = await _storage.getShortcuts();
      if (!mounted) return;
      
      setState(() {
        shortcuts = loadedShortcuts;
        _filterShortcuts(_searchController.text);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading shortcuts: $e');
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterShortcuts(String query) {
    if (!mounted) return;
    
    setState(() {
      filteredShortcuts = shortcuts.where((shortcut) {
        return shortcut.key.toLowerCase().contains(query.toLowerCase()) ||
               shortcut.description.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _addShortcut() async {
    final result = await showDialog<Shortcut>(
      context: context,
      builder: (context) => AddShortcutDialog(),
    );

    if (result != null && mounted) {
      setState(() {
        shortcuts.add(result);
        _filterShortcuts(_searchController.text);
      });
      await _storage.saveShortcuts(shortcuts);
    }
  }

  Future<void> _deleteShortcut(Shortcut shortcut) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Shortcut'),
        content: Text('Are you sure you want to delete "${shortcut.key}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        shortcuts.remove(shortcut);
        _filterShortcuts(_searchController.text);
      });
      await _storage.saveShortcuts(shortcuts);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('URL Shortcuts'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search shortcuts',
                hintText: 'Type to filter shortcuts',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterShortcuts,
            ),
            const SizedBox(height: 16),
            const Text(
              'Type "go" in Chrome\'s address bar, then your shortcut',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (filteredShortcuts.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No shortcuts found.\nClick + to add a new shortcut.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: filteredShortcuts.length,
                  itemBuilder: (context, index) {
                    final shortcut = filteredShortcuts[index];
                    return Card(
                      child: ListTile(
                        title: Text(shortcut.key),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(shortcut.description),
                            Text(
                              'URL: ${shortcut.url}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteShortcut(shortcut),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addShortcut,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class AddShortcutDialog extends StatefulWidget {
  @override
  State<AddShortcutDialog> createState() => _AddShortcutDialogState();
}

class _AddShortcutDialogState extends State<AddShortcutDialog> {
  final _formKey = GlobalKey<FormState>();
  final _keyController = TextEditingController();
  final _urlController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Shortcut'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _keyController,
              decoration: const InputDecoration(
                labelText: 'Shortcut Key',
                hintText: 'e.g., g for Google',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a shortcut key';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL Pattern',
                hintText: 'e.g., https://google.com/search?q={query}',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a URL pattern';
                }
                if (!value.contains('{query}')) {
                  return 'URL must contain {query}';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'e.g., Search Google',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(
                context,
                Shortcut(
                  key: _keyController.text,
                  url: _urlController.text,
                  description: _descriptionController.text,
                ),
              );
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _keyController.dispose();
    _urlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
