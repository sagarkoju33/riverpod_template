import 'package:auth_app/src/features/auth/controller/auth_controller.dart';
import 'package:auth_app/src/features/feed/controller/feed_controller.dart';
import 'package:auth_app/src/resources/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeedView extends ConsumerStatefulWidget {
  const FeedView({super.key});
  static const routePath = '/feedback';
  @override
  ConsumerState<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends ConsumerState<FeedView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(feedControllerProvider.notifier).getFeed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Protected Page"),
        actions: [
          ElevatedButton(
            onPressed: () {
              ref.read(authControllerProvider.notifier).signout();
            },
            child: Text("Log out"),
          ),
        ],
      ),
      body: Column(
        children: [
          Assets.images.profileimage.image(),
          Consumer(
            builder: (context, ref, child) {
              final state = ref.watch(feedControllerProvider);

              if (state.loading) {
                return Center(child: CircularProgressIndicator());
              }

              if (state.posts.isEmpty) {
                return Center(child: Text("No posts yet"));
              }

              return ListView.builder(
                itemCount: state.posts.length,
                itemBuilder: (context, index) {
                  final post = state.posts[index];

                  return ListTile(
                    title: Text(post.name),
                    subtitle: Text(post.post),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
