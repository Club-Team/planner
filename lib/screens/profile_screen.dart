import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:dayline_planner/providers/task_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:dayline_planner/providers/theme_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dayline_planner/screens/edit_sections_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _photoPath;
  late TextEditingController _nickController;

  @override
  void initState() {
    super.initState();
    _nickController = TextEditingController();
    _loadPrefs();
  }

  @override
  void dispose() {
    _nickController.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final storedPhoto = prefs.getString('avatarPath');
    final storedNick = prefs.getString('nickname') ?? '';
    setState(() {
      _photoPath = storedPhoto;
      _nickController.text = storedNick;
    });
  }

  Future<void> _pickPhoto() async {
    print('[ProfileScreen] _pickPhoto() called');

    File? imageFile;

    try {
      if (Platform.isIOS || Platform.isAndroid) {
        print('[ProfileScreen] Platform is mobile — using image_picker');

        final picker = ImagePicker();
        final picked =
            await picker.pickImage(source: ImageSource.gallery, maxWidth: 600);
        print('[ProfileScreen] Picker result: ${picked?.path ?? "null"}');

        if (picked == null) {
          print('[ProfileScreen] No image selected — picker returned null');
          return;
        }

        imageFile = File(picked.path);
      } else {
        print('[ProfileScreen] Platform is desktop — using file_picker');

        final result =
            await FilePicker.platform.pickFiles(type: FileType.image);
        print(
            '[ProfileScreen] FilePicker result: ${result?.files.map((f) => f.path).toList() ?? "null"}');

        if (result == null || result.files.isEmpty) {
          print(
              '[ProfileScreen] No image selected — file picker returned null/empty');
          return;
        }

        imageFile = File(result.files.single.path!);
      }

      // Copy to app documents directory
      print('[ProfileScreen] Copying file...');
      final appDir = await getApplicationDocumentsDirectory();
      print('[ProfileScreen] Documents dir: ${appDir.path}');

      final fileName = p.basename(imageFile.path);
      final saved = await imageFile.copy('${appDir.path}/$fileName');
      print('[ProfileScreen] Saved image to: ${saved.path}');

      // Save path to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('avatarPath', saved.path);
      print('[ProfileScreen] Saved path to prefs');

      if (!mounted) {
        print('[ProfileScreen] Widget no longer mounted — skipping setState');
        return;
      }

      setState(() {
        _photoPath = saved.path;
        print('[ProfileScreen] State updated with photoPath=$_photoPath');
      });
    } catch (e, stack) {
      print('[ProfileScreen] ❌ Error in _pickPhoto: $e');
      print(stack);
    }
  }

  Future<void> _saveNick() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nickname', _nickController.text.trim());

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context, listen: true);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final doneCount = provider.totalCompletedCount();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickPhoto,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    _photoPath != null ? FileImage(File(_photoPath!)) : null,
                child: _photoPath == null
                    ? const Icon(Icons.person, size: 50, color: Colors.white70)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nickController,
              decoration: const InputDecoration(
                labelText: 'Nickname',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _saveNick,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
            const SizedBox(height: 24),
            Text(
              'Tasks completed: $doneCount',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text("Dark Mode"),
              value: themeProvider.isDarkMode,
              onChanged: (val) => themeProvider.toggleTheme(val),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.view_list),
              label: const Text('Edit Planner Sections'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditSectionsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
