import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddHardwarePage extends StatefulWidget {
  @override
  _AddHardwarePageState createState() => _AddHardwarePageState();
}

class _AddHardwarePageState extends State<AddHardwarePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  String _availability = 'Available';

  Future<void> _addHardware() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _departmentController.text.isEmpty ||
        _yearController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    int? year = int.tryParse(_yearController.text);
    if (year == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Year must be a number')),
      );
      return;
    }

    String docId = FirebaseFirestore.instance.collection('hardwares').doc().id;

    await FirebaseFirestore.instance.collection('hardwares').doc(docId).set({
      'Title': _titleController.text,
      'Description': _descriptionController.text,
      'Department': _departmentController.text,
      'Year': year,
      'Availability': _availability,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Hardware added successfully')),
    );

    _titleController.clear();
    _descriptionController.clear();
    _departmentController.clear();
    _yearController.clear();
    setState(() {
      _availability = 'Available';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Hardware')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _departmentController,
              decoration: InputDecoration(labelText: 'Department'),
            ),
            TextField(
              controller: _yearController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Year'),
            ),
            DropdownButtonFormField(
              value: _availability,
              items: ['Available', 'Lent'].map((String category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _availability = value.toString();
                });
              },
              decoration: InputDecoration(labelText: 'Availability'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addHardware,
              child: Text('Add Hardware'),
            ),
          ],
        ),
      ),
    );
  }
}
