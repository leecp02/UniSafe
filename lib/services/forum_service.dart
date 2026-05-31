import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/forum_post_model.dart';

class ForumService {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // CREATE POST
  Future<void> createPost(ForumPost post) async {
    try {

      await firestore.collection("forum_posts").add({
        ...post.toMap(),
        "attachments": post.attachments
            .map((a) => a.toMap())
            .toList(),
        "createdAt": FieldValue.serverTimestamp(),
      });

    } on FirebaseException catch (e) {
      final message = e.message ?? "Unknown Firestore create error.";
      throw Exception("Create post failed [${e.code}]: $message");
    }
  }

  // UPDATE POST
  Future<void> updatePost({
    required String postId,
    required String postTitle,
    required String postDesc,
    required String userId,
    required DateTime createdAt,
    List<Map<String, dynamic>>? attachments, // optional
  }) async {

    try {

      Map<String, dynamic> data = {
        "postTitle": postTitle,
        "postDesc": postDesc,
        "userId": userId,
        "createdAt": createdAt,
      };

      // Only update attachments if provided
      if (attachments != null) {
        data["attachments"] = attachments;
      }

      await firestore
          .collection("forum_posts")
          .doc(postId)
          .update(data);

    } on FirebaseException catch (e) {

      final String message =
          e.message ?? "Unknown Firestore update error.";

      throw Exception("Update post failed [${e.code}]: $message");
    }
  }

  // GET POSTS
  Stream<List<ForumPost>> getPosts() {

    return firestore
        .collection("forum_posts")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {

      return snapshot.docs.map((doc) {

        return ForumPost.fromMap(
          doc.id,
          doc.data(),
        );

      }).toList();
    });
  }
}