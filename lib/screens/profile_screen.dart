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
    final totalTasks = provider.tasks.length;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.cardColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header card with gradient, avatar and quick stats
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primary.withOpacity(0.95),
                    primary.withOpacity(0.75),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: _pickPhoto,
                            child: CircleAvatar(
                              radius: 44,
                              backgroundColor: theme.cardColor.withOpacity(0.15),
                              backgroundImage: _photoPath != null
                                  ? FileImage(File(_photoPath!))
                                  : null,
                              child: _photoPath == null
                                  ? Icon(
                                      Icons.person,
                                      size: 44,
                                      color: onPrimary.withOpacity(0.85),
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: InkWell(
                              onTap: _pickPhoto,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: theme.cardColor.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nickController.text.isEmpty
                                  ? 'Your profile'
                                  : _nickController.text.trim(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Plan your day smartly',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: onPrimary.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatChip(
                          label: 'Completed',
                          value: doneCount.toString(),
                          icon: Icons.check_circle,
                          color: theme.cardColor,
                          textColor: primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatChip(
                          label: 'Tasks',
                          value: totalTasks.toString(),
                          icon: Icons.list_alt,
                          color: theme.cardColor,
                          textColor: primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Profile info card (match planner-style shadow)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile info',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nickController,
                      textInputAction: TextInputAction.done,
                      cursorColor: primary,
                      onSubmitted: (_) => _saveNick(),
                      decoration: InputDecoration(
                        labelText: 'Nickname',
                        prefixIcon: const Icon(Icons.person_outline),
                        fillColor: theme.scaffoldBackgroundColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: _saveNick,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Save changes'),
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Preferences card (match planner-style shadow)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    value: themeProvider.isDarkMode,
                    onChanged: (val) => themeProvider.toggleTheme(val),
                    title: const Text('Dark mode'),
                    secondary: const Icon(Icons.dark_mode_outlined),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.view_list_outlined),
                    title: const Text('Edit planner sections'),
                    subtitle: const Text('Customize categories for your tasks'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EditSectionsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color textColor;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: textColor),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textColor.withOpacity(0.8),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
