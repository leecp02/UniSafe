import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/event_controller.dart';
import '../models/event_post_model.dart';
import '../style/style.dart';

class CreateEventPostPage extends StatefulWidget {
  final EventPost? initialEvent;

  const CreateEventPostPage({
    super.key,
    this.initialEvent,
  });

  @override
  State<CreateEventPostPage> createState() => _CreateEventPostPageState();
}

class _CreateEventPostPageState extends State<CreateEventPostPage> {

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController venueController = TextEditingController();
  final EventController eventController = EventController();

  DateTime? selectedDate;
  final List<XFile> selectedFiles = [];
  final List<Uint8List> selectedImageBytes = [];
  bool isPosting = false;

  bool get isEditMode => widget.initialEvent != null;

  @override
  void initState() {
    super.initState();

    if (isEditMode) {
      titleController.text = widget.initialEvent!.eventTitle;
      descController.text = widget.initialEvent!.eventDesc;
      venueController.text = widget.initialEvent!.eventVenue;
      selectedDate = widget.initialEvent!.eventDate;
    }
  }

  Future<void> pickDate() async {

    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> pickFiles() async {

    final picked = await ImagePicker().pickMultiImage(
      imageQuality: 60,
      maxWidth: 900,
      maxHeight: 900,
    );

    if (picked.isNotEmpty) {
      final List<Uint8List> bytesList =
          await Future.wait(picked.map((file) => file.readAsBytes()));

      setState(() {
        selectedFiles.addAll(picked);
        selectedImageBytes.addAll(bytesList);
      });
    }
  }

  Future<void> submitEvent() async {
    if (isPosting) {
      return;
    }

    if (titleController.text.trim().isEmpty &&
        descController.text.trim().isEmpty &&
        venueController.text.trim().isEmpty &&
        selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all the fields')),
      );
      return;
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select event date.')),
      );
      return;
    }

    setState(() => isPosting = true);

    try {
      if (isEditMode) {
        await eventController.updateEvent(
          eventId: widget.initialEvent!.eventId,
          eventTitle: titleController.text,
          eventDesc: descController.text,
          eventDate: selectedDate!,
          eventVenue: venueController.text,
          existingUserId: widget.initialEvent!.userId,
          existingCreatedAt: widget.initialEvent!.createdAt,
          existingAttachments: widget.initialEvent!.attachments,
          attachmentFiles: selectedFiles.isEmpty ? null : selectedFiles,
        );
      } else {
        await eventController.createEvent(
          eventTitle: titleController.text,
          eventDesc: descController.text,
          eventDate: selectedDate!,
          eventVenue: venueController.text,
          attachmentFiles: selectedFiles.isEmpty ? null : selectedFiles,
        );
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditMode
                ? 'Event updated successfully.'
                : 'Event posted successfully.',
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => isPosting = false);
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    venueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Event Post' : 'Event Post',
          style: CustomStyle.h4,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Create event:', style: CustomStyle.h4),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          readOnly: true,
                          onTap: pickDate,
                          decoration: InputDecoration(
                            labelText: selectedDate == null
                                ? 'Date'
                                : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                            suffixIcon: const Icon(Icons.calendar_today),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: venueController,
                          decoration: const InputDecoration(
                            labelText: 'Venue',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: descController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: pickFiles,
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.upload_file),
                                const SizedBox(width: 6),
                                Text(
                                  selectedFiles.isEmpty
                                      ? 'Add Images (Optional)'
                                      : 'Add More Images',
                                  style: CustomStyle.txt,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (selectedFiles.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 110,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: selectedFiles.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        child: Image.memory(
                                          selectedImageBytes[index],
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
                                              selectedFiles.removeAt(index);
                                              selectedImageBytes.removeAt(index);
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius:
                                                  BorderRadius.circular(20),
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
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CustomStyle.primary,
                              ),
                              onPressed: isPosting ? null : submitEvent,
                              child: isPosting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      isEditMode ? 'Save' : 'Post',
                                      style: CustomStyle.lightTxt,
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isPosting)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}