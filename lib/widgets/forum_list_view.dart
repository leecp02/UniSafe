import 'package:flutter/material.dart';
import '../controllers/forum_controller.dart';
import '../models/forum_post_model.dart';
import 'post_card.dart';

class ForumListView extends StatelessWidget {

  final ForumController controller;

  const ForumListView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<List<ForumPost>>(

      stream: controller.getPosts(),

      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text("No forum posts yet"),
          );
        }

        List<ForumPost> posts = snapshot.data!;

        return ListView.builder(

          padding: const EdgeInsets.all(12),

          itemCount: posts.length,

          itemBuilder: (context, index) {

            return PostCard(
              post: posts[index],
              controller: controller,
            );

          },
        );
      },
    );
  }
}