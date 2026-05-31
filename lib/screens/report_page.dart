import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/report_controller.dart';
import '../models/report_model.dart';
import 'records_page.dart';
import '../style/style.dart';

class ReportPage extends StatefulWidget {
  final Report? initialReport;

  const ReportPage({super.key, this.initialReport});

  bool get isEditing => initialReport != null;

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final ReportController _controller = ReportController();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> _categories = <String>[
    'Safety',
    'Harassment',
    'Theft',
    'Medical',
    'Other',
  ];

  final Map<String, List<String>> _tagsByCategory = <String, List<String>>{
    'Safety': <String>['Hazard', 'Suspicious Activity', 'Violence'],
    'Harassment': <String>['Verbal', 'Physical', 'Cyber'],
    'Theft': <String>['Phone', 'Wallet', 'Vehicle', 'Other Item'],
    'Medical': <String>['Injury', 'Emergency', 'Mental Health'],
    'Other': <String>['General', 'Unknown'],
  };

  String? _selectedCategory;
  String? _selectedTag;
  DateTime? _selectedDateTime;

  final List<Uint8List> _existingEvidenceBytes = <Uint8List>[];
  final List<XFile> _selectedEvidenceFiles = <XFile>[];
  final List<Uint8List> _selectedEvidenceBytes = <Uint8List>[];

  bool _isSubmitting = false;
  bool _showRecords = false;

  @override
  void initState() {
    super.initState();
    final report = widget.initialReport;
    if (report == null) {
      return;
    }

    _titleController.text = report.title;
    _locationController.text = report.location;
    _descriptionController.text = report.description;
    _selectedCategory = report.category;
    _selectedTag = report.tag;
    _selectedDateTime = report.dateTime;

    if (report.attachments.isNotEmpty) {
      for (final attachment in report.attachments) {
        final String attachmentData =
            (attachment['attachmentData'] ?? '').toString();
        if (attachmentData.isEmpty) {
          continue;
        }

        try {
          _existingEvidenceBytes.add(base64Decode(attachmentData));
        } catch (_) {
          // Skip malformed attachments in edit preview.
        }
      }
    }
  }

  String get _dateTimeDisplay {
    if (_selectedDateTime == null) return '';
    final dt = _selectedDateTime!;
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year.toString();
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  List<String> get _tagOptions {
    if (_selectedCategory == null) return const <String>[];
    return _tagsByCategory[_selectedCategory] ?? const <String>[];
  }

  Future<void> _pickDateTime() async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
    );

    if (pickedDate == null || !mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? now),
    );

    if (pickedTime == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _pickEvidence() async {
    final List<XFile> picked = await ImagePicker().pickMultiImage(
      imageQuality: 60,
      maxWidth: 900,
      maxHeight: 900,
    );

    if (picked.isEmpty) return;

    final List<Uint8List> bytesList =
        await Future.wait(picked.map((file) => file.readAsBytes()));

    if (!mounted) return;

    setState(() {
      _selectedEvidenceFiles.addAll(picked);
      _selectedEvidenceBytes.addAll(bytesList);
    });
  }

  void _clearForm() {
    _titleController.clear();
    _locationController.clear();
    _descriptionController.clear();

    setState(() {
      _selectedCategory = null;
      _selectedTag = null;
      _selectedDateTime = null;
      _selectedEvidenceFiles.clear();
      _selectedEvidenceBytes.clear();
      if (!widget.isEditing) {
        _existingEvidenceBytes.clear();
      }
    });
  }

  void _handleCancel() {
    if (widget.isEditing) {
      Navigator.pop(context);
      return;
    }

    _clearForm();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    // If the user left every field blank, show a complete-all-fields message
    if (_titleController.text.trim().isEmpty &&
        (_selectedCategory == null || _selectedCategory!.trim().isEmpty) &&
        (_selectedTag == null || _selectedTag!.trim().isEmpty) &&
        _selectedDateTime == null &&
        _locationController.text.trim().isEmpty &&
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all the fields')),
      );
      return;
    }

    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select DateTime.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (widget.isEditing) {
        await _controller.updateReport(
          report: widget.initialReport!,
          title: _titleController.text,
          category: _selectedCategory ?? '',
          tag: _selectedTag ?? '',
          dateTime: _selectedDateTime!,
          location: _locationController.text,
          description: _descriptionController.text,
          evidenceFiles: _selectedEvidenceFiles.isEmpty
              ? null
              : _selectedEvidenceFiles,
        );
      } else {
        await _controller.createReport(
          title: _titleController.text,
          category: _selectedCategory ?? '',
          tag: _selectedTag ?? '',
          dateTime: _selectedDateTime!,
          location: _locationController.text,
          description: _descriptionController.text,
          evidenceFiles: _selectedEvidenceFiles.isEmpty
              ? null
              : _selectedEvidenceFiles,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Report updated successfully.'
                : 'Report submitted successfully.',
          ),
        ),
      );

      if (widget.isEditing) {
        Navigator.pop(context);
      } else {
        _clearForm();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEditing) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: _buildTopCard(
                    title: 'Report',
                    icon: Icons.report_outlined,
                    isActive: !_showRecords,
                    onTap: () {
                      setState(() {
                        _showRecords = false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTopCard(
                    title: 'Records',
                    icon: Icons.folder_outlined,
                    isActive: _showRecords,
                    onTap: () {
                      setState(() {
                        _showRecords = true;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _showRecords
                ? const RecordsListSection(isCounsellor: false)
                : _buildReportForm(),
          ),
        ],
      );
    }

    return _buildReportForm();
  }

  Widget _buildTopCard({
    required String title,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: isActive ? 2 : 0,
      color: isActive ? Theme.of(context).colorScheme.primaryContainer : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Column(
            children: [
              Icon(
                icon,
                color: isActive ? Theme.of(context).colorScheme.primary : Colors.black54,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isActive ? Theme.of(context).colorScheme.primary : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportForm() {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.isEditing ? 'Edit submitted report:' : 'Report an incident:',
                style: CustomStyle.h4,
              ),
              const SizedBox(height: 8),
              Text(
                widget.isEditing
                    ? 'Update the fields below and save your changes.'
                    : 'Fill in the fields below to submit your report.',
                style: CustomStyle.txt,
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildTextField(label: 'Title:', controller: _titleController),
                    const SizedBox(height: 10),
                    _buildCategoryField(),
                    const SizedBox(height: 10),
                    _buildTagField(),
                    const SizedBox(height: 10),
                    _buildDateTimeField(),
                    const SizedBox(height: 10),
                    _buildTextField(label: 'Location:', controller: _locationController),
                    const SizedBox(height: 10),
                    _buildDescriptionField(),
                    const SizedBox(height: 10),
                    _buildUploadRow(),
                    if (_existingEvidenceBytes.isNotEmpty) ...<Widget>[
                      Text('Existing attachments:', style: CustomStyle.subtitle),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 110,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _existingEvidenceBytes.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  _existingEvidenceBytes[index],
                                  height: 110,
                                  width: 110,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    if (_selectedEvidenceBytes.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 10),
                      Text('New attachments:', style: CustomStyle.subtitle),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 110,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedEvidenceBytes.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: <Widget>[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      _selectedEvidenceBytes[index],
                                      height: 110,
                                      width: 110,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    right: 4,
                                    top: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedEvidenceFiles.removeAt(index);
                                          _selectedEvidenceBytes.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.all(4),
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        OutlinedButton(
                          onPressed: _isSubmitting ? null : _handleCancel,
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _isSubmitting ? null : _submit,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(widget.isEditing ? 'Update' : 'Submit'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_isSubmitting)
          Container(
            color: Colors.black.withOpacity(0.2),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return Row(
      children: <Widget>[
        SizedBox(width: 74, child: Text(label, style: CustomStyle.txt)),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryField() {
    return Row(
      children: <Widget>[
        SizedBox(width: 74, child: Text('Category:', style: CustomStyle.txt)),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedCategory,
            isExpanded: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            items: _categories
                .map((String c) => DropdownMenuItem<String>(
                      value: c,
                      child: Text(c),
                    ))
                .toList(),
            onChanged: (String? value) {
              setState(() {
                _selectedCategory = value;
                if (!_tagOptions.contains(_selectedTag)) {
                  _selectedTag = null;
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTagField() {
    return Row(
      children: <Widget>[
        SizedBox(width: 74, child: Text('Tag:', style: CustomStyle.txt)),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedTag,
            isExpanded: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            items: _tagOptions
                .map((String tag) => DropdownMenuItem<String>(
                      value: tag,
                      child: Text(tag),
                    ))
                .toList(),
            onChanged: _selectedCategory == null
                ? null
                : (String? value) {
                    setState(() {
                      _selectedTag = value;
                    });
                  },
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeField() {
    return Row(
      children: <Widget>[
        SizedBox(width: 74, child: Text('DateTime:', style: CustomStyle.txt)),
        Expanded(
          child: InkWell(
            onTap: _pickDateTime,
            child: InputDecorator(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              child: Text(
                _dateTimeDisplay.isEmpty ? 'Select date & time' : _dateTimeDisplay,
                style: _dateTimeDisplay.isEmpty
                    ? CustomStyle.subtitle
                    : CustomStyle.txt,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Description:', style: CustomStyle.txt),
        const SizedBox(height: 6),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Describe what happened',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadRow() {
    return Row(
      children: <Widget>[
        Text('Upload Evidence:', style: CustomStyle.txt),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: _pickEvidence,
            child: Container(
              height: 34,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  _selectedEvidenceFiles.isEmpty ? 'Add Images' : 'Add More',
                  style: CustomStyle.txt,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
