import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:post_composer/models/slide.dart';
import 'package:post_composer/util/styles.dart';
import '../models/post.dart';
import 'post_composer.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';

class PostListHomePage extends HookWidget {
  const PostListHomePage({super.key}) : super();

  @override
  Widget build(BuildContext context) {
    final posts = useState<List<Post>>([]);

    Future<void> loadPosts() async {
      List<Post> dbPosts = await getPosts();
      for (Post post in dbPosts) {
        List<Slide> postSlides = await getSlidesForPost(post.id!);
        if (postSlides.isNotEmpty) post.slides = postSlides;
      }

      posts.value = dbPosts;
    }

    useEffect(() {
      loadPosts();
      return;
    }, const []);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Rishi's Instagram Post Composer"),
        trailing: CupertinoButton(
          padding: const EdgeInsets.all(0.0),
          onPressed: () async {
            await Navigator.of(context).push(
              CupertinoPageRoute<void>(
                builder: (BuildContext context) {
                  return PostComposer(loadedPost: Post(name: "New Post"));
                },
              ),
            );
            loadPosts();
          },
          child: const Icon(CupertinoIcons.plus),
        ),
      ),
      child: SafeArea(
        child: posts.value.isNotEmpty
            ? CupertinoListSection.insetGrouped(
                children: posts.value
                    .map((Post p) => PostListItem(
                          post: p,
                          loadPosts: loadPosts,
                        ))
                    .toList())
            : const Empty(),
      ),
    );
  }
}

class PostListItem extends StatelessWidget {
  const PostListItem({
    super.key,
    required this.post,
    required this.loadPosts,
  }) : super();

  final Post post;
  final Function loadPosts;

  @override
  Widget build(BuildContext context) {
    return SwipeActionCell(
      key: ObjectKey(post),
      trailingActions: <SwipeAction>[
        SwipeAction(
            icon: const Icon(
              CupertinoIcons.trash,
              color: CupertinoColors.white,
            ),
            widthSpace: 60,
            onTap: (CompletionHandler handler) async {
              _showDeleteAlert(context, post.id!, loadPosts);
            },
            color: CupertinoColors.destructiveRed),
      ],
      child: CupertinoListTile.notched(
        title: Text(post.name),
        subtitle: Text(post.dateString()),
        additionalInfo: Text('${post.slides.length} slides'),
        trailing: const CupertinoListTileChevron(),
        backgroundColor: CupertinoColors.white,
        onTap: () async {
          await Navigator.of(context).push(CupertinoPageRoute<void>(
            builder: (BuildContext context) {
              return PostComposer(loadedPost: post);
            },
          ));
          loadPosts();
        },
      ),
    );
  }
}

void _showDeleteAlert(BuildContext context, int postId, Function loadPosts) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: const Text("Delete post?"),
      content: const Text("This action cannot be undone."),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('No'),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () async {
            Navigator.pop(context);
            await deletePost(postId);
            await loadPosts();
          },
          child: const Text('Yes'),
        ),
      ],
    ),
  );
}

class Empty extends StatelessWidget {
  const Empty({super.key}) : super();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Transform.scale(
            scale: 2,
            child: Icon(
              CupertinoIcons.rocket_fill,
              color: Styles.shadowGrey,
            ),
          ),
          const SizedBox(height: 30.0),
          const Text("Let's get started!")
        ],
      ),
    );
  }
}
