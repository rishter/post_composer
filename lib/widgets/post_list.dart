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
        middle: const Text("Rishi's IG Composer"),
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
          child: const Text('New Post'),
        ),
      ),
      child: SafeArea(
        child: posts.value.isNotEmpty
            ? CupertinoListSection.insetGrouped(
                children: posts.value
                    .map((Post p) => CupertinoListTile.notched(
                          title: Text(p.name),
                          subtitle: Text(p.dateString()),
                          additionalInfo: Text('${p.slides.length} slides'),
                          trailing: const CupertinoListTileChevron(),
                          onTap: () async {
                            await Navigator.of(context)
                                .push(CupertinoPageRoute<void>(
                              builder: (BuildContext context) {
                                return PostComposer(loadedPost: p);
                              },
                            ));
                            loadPosts();
                          },
                        ))
                    .toList())
            : const Empty(),
      ),
    );
  }
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
