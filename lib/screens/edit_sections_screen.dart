import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dayline_planner/providers/section_provider.dart';

class EditSectionsScreen extends StatefulWidget {
  @override
  State<EditSectionsScreen> createState() => _EditSectionsScreenState();
}

class _EditSectionsScreenState extends State<EditSectionsScreen> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final sectionProvider = Provider.of<SectionProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Edit Sections')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: sectionProvider.sections
                  .map((s) => ListTile(
                        title: Text(s),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => sectionProvider.removeSection(s),
                        ),
                      ))
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(labelText: 'New section'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      sectionProvider.addSection(_controller.text.trim());
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
