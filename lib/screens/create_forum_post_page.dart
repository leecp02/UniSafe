import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/forum_controller.dart';
import '../models/forum_post_model.dart';
import '../style/style.dart';

class CreateForumPostPage extends StatefulWidget {
  final ForumPost? initialPost;

  const CreateForumPostPage({
    super.key,
    this.initialPost,
  });

  @override
  State<CreateForumPostPage> createState() =>
      _CreateForumPostPageState();
}

class _CreateForumPostPageState
    extends State<CreateForumPostPage> {

  final TextEditingController titleController =
      TextEditingController();
  final TextEditingController descController =
      TextEditingController();

  final ForumController forumController = ForumController();

  final List<XFile> selectedFiles = [];
  final List<Uint8List> selectedImageBytes = [];
  bool isPosting = false;

  bool get isEditMode => widget.initialPost != null;

  @override
  void initState() {
    super.initState();

    if (isEditMode) {
      titleController.text =
          widget.initialPost!.postTitle;
      descController.text =
          widget.initialPost!.postDesc;
    }
  }

  // PICK IMAGES
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

  // SUBMIT POST
  Future<void> submitPost() async {

    if (isPosting) return;

    final title = titleController.text.trim();
    final desc = descController.text.trim();

    if (title.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Title and description required"),
        ),
      );
      return;
    }

    setState(() => isPosting = true);

    try {

      if (isEditMode) {
        await forumController.updatePost(
          postId: widget.initialPost!.postId,
          postTitle: title,
          postDesc: desc,
          existingUserId: widget.initialPost!.userId,
          existingCreatedAt:
              widget.initialPost!.createdAt,
          attachmentFiles:
              selectedFiles.isEmpty ? null : selectedFiles,
        );
      } else {
        await forumController.createPost(
          postTitle: title,
          postDesc: desc,
          attachmentFiles:
              selectedFiles.isEmpty ? null : selectedFiles,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditMode
                ? "Post updated successfully"
                : "Post created successfully",
          ),
        ),
      );

      Navigator.pop(context);

    } catch (e) {

      if (!mounted) return;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(
          isEditMode ? "Edit Forum Post" : "Forum Post",
          style: CustomStyle.h4,
        ),
      ),

      body: Stack(
        children: [

          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text("Write something:",
                    style: CustomStyle.h4),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius:
                        BorderRadius.circular(12),
                  ),

                  child: Column(
                    children: [

                      TextField(
                        controller: titleController,
                        decoration:
                            const InputDecoration(
                          labelText: "Title",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: descController,
                        maxLines: 4,
                        decoration:
                            const InputDecoration(
                          labelText: "Description",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // PICK FILE BUTTON
                      GestureDetector(
                        onTap: pickFiles,
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.upload_file),
                              const SizedBox(width: 6),
                              Text(
                                selectedFiles.isEmpty
                                    ? "Add Images (Optional)"
                                    : "Add More Images",
                                style: CustomStyle.txt,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // IMAGE PREVIEW
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
                                      borderRadius: BorderRadius.circular(8),
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

                      if (isEditMode &&
                          selectedFiles.isEmpty &&
                          widget.initialPost!
                              .attachments.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          "Existing attachment will remain",
                          style: CustomStyle.subtitle,
                        ),
                      ],

                      const SizedBox(height: 6),

                      Text(
                        "Attachment is optional",
                        style: CustomStyle.subtitle,
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.end,
                        children: [

                          OutlinedButton(
                            onPressed: () =>
                                Navigator.pop(context),
                            child: const Text(
                              "Cancel",
                              style:
                                  TextStyle(color: Colors.red),
                            ),
                          ),

                          const SizedBox(width: 10),

                          ElevatedButton(
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  CustomStyle.primary,
                            ),
                            onPressed:
                                isPosting ? null : submitPost,
                            child: isPosting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text("Post",
                                    style:
                                        CustomStyle.lightTxt),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),

          // 🔥 FULL SCREEN LOADING OVERLAY
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