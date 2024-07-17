import 'package:post_composer/models/post.dart';
import 'package:post_composer/models/slide.dart';

import '../util/styles.dart';
import '../util/image_util.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:card_swiper/card_swiper.dart';

class PostComposer extends HookWidget {
  const PostComposer({
    super.key,
    required this.loadedPost,
  }) : super();

  final Post loadedPost;

  @override
  Widget build(BuildContext context) {
    final editingMode = useState(false);
    final imageKeys = useState<List<GlobalKey>>(
        [for (var i = 0; i < loadedPost.slides.length; i++) GlobalKey()]);
    final slideState = useState<List<Slide>>(loadedPost.slides);
    final postState = useState<Post>(loadedPost);
    final initialLoading = useState<bool>(true);

    final swiperController = useMemoized(() => SwiperController(), []);

    canAddNewSlide() =>
        slideState.value.length < 10 && postState.value.id != null;
    canRemoveSlide() => slideState.value.length > 1;

    void loadSlides() async {
      if (postState.value.id != null) {
        List<Slide> slides = await getSlidesForPost(postState.value.id!);
        if (slides.isEmpty) {
          Slide first = await upsertSlide(
              Slide(postId: postState.value.id!, position: 0, content: ''));
          slideState.value = [first];
        } else {
          slideState.value = slides;
        }
        initialLoading.value = false;
      }
    }

    Future<void> saveSlide(int position, String content) async {
      if (postState.value.id != null) {
        Slide newSlide = await upsertSlide(Slide(
          postId: postState.value.id!,
          position: position,
          content: content,
        ));

        final newSlideState = List<Slide>.from(slideState.value);
        newSlideState[position] = newSlide;
        slideState.value = newSlideState;
      }
    }

    useEffect(() {
      loadSlides();
      return;
    }, [postState.value.id]);

    Future<void> addSlide() async {
      if (!canAddNewSlide()) return;

      final oldCount = slideState.value.length;
      editingMode.value = false;

      final newSlideState = List<Slide>.from(slideState.value);
      newSlideState.add(Slide(position: oldCount, content: ""));
      slideState.value = newSlideState;

      final newImageKeys = List<GlobalKey>.from(imageKeys.value);
      newImageKeys.add(GlobalKey());
      imageKeys.value = newImageKeys;

      await saveSlide(oldCount, "");

      swiperController.move(oldCount);
    }

    void removeSlide(index) async {
      if (!canRemoveSlide()) return;
      swiperController.previous();

      editingMode.value = false;

      List<Slide> newSlideState =
          await deleteSlideCascade(postState.value.id!, index);

      slideState.value = newSlideState;

      final newImageKeys = List<GlobalKey>.from(imageKeys.value);
      newImageKeys.removeAt(index);
      imageKeys.value = newImageKeys;
    }

    Future<void> captureAndSaveImages() async {
      editingMode.value = false; // Ensure we're not in editing mode
      await saveImages(imageKeys.value, (index) async {
        swiperController.move(index);
      });
    }

    return CupertinoPageScaffold(
      backgroundColor: Styles.backgroundGrey,
      navigationBar: CupertinoNavigationBar(
        middle: PostTitle(postState: postState),
        trailing: CupertinoButton(
          padding: const EdgeInsets.all(10.0),
          onPressed: canAddNewSlide() ? addSlide : null,
          child: const Icon(CupertinoIcons.plus),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Transform.scale(
                  scale: 0.97,
                  child: PostSwiper(
                    post: postState.value,
                    swiperController: swiperController,
                    editingMode: editingMode,
                    imageKeys: imageKeys.value,
                    slideState: slideState,
                    removeSlide: removeSlide,
                    saveSlide: saveSlide,
                  ),
                ),
              ),
            ),
            CupertinoButton(
              onPressed: editingMode.value ? null : captureAndSaveImages,
              child: Text(slideState.value.length > 1
                  ? 'Download Images'
                  : 'Download Image'),
            ),
          ],
        ),
      ),
    );
  }
}

class PostTitle extends HookWidget {
  const PostTitle({super.key, required this.postState}) : super();

  final ValueNotifier<Post> postState;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: postState.value.name);
    final focusNode = useFocusNode();

    savePost(name) async {
      Post newPost = Post(
          id: postState.value.id,
          name: name,
          createdAt: postState.value.createdAt);
      postState.value = await upsertPost(newPost);
    }

    return CupertinoTextField.borderless(
      padding: const EdgeInsets.all(0.0),
      textAlign: TextAlign.center,
      style: Styles.titleStyle,
      focusNode: focusNode,
      controller: controller,
      autofocus: true,
      maxLength: 27,
      enableSuggestions: false,
      spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
      onChanged: savePost,
    );
  }
}

class PostSwiper extends HookWidget {
  const PostSwiper({
    super.key,
    required this.post,
    required this.swiperController,
    required this.editingMode,
    required this.imageKeys,
    required this.slideState,
    required this.removeSlide,
    required this.saveSlide,
  }) : super();

  final Post post;
  final SwiperController swiperController;
  final ValueNotifier<bool> editingMode;
  final List<GlobalKey> imageKeys;
  final ValueNotifier<List<Slide>> slideState;
  final Function(int) removeSlide;
  final Function(int, String) saveSlide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Styles.sqDimension,
      height: Styles.sqDimension,
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Swiper(
        itemCount: slideState.value.length,
        itemBuilder: (BuildContext context, int index) {
          return RepaintBoundary(
            key: imageKeys[index],
            child: CupertinoContextMenu(
              actions: [
                CupertinoContextMenuAction(
                  onPressed: () {
                    saveSlide(index, "");
                    Navigator.pop(context);
                  },
                  trailingIcon: CupertinoIcons.refresh,
                  child: const Text('Clear Slide'),
                ),
                CupertinoContextMenuAction(
                  onPressed: () {
                    Navigator.pop(context);
                    removeSlide(index);
                  },
                  isDestructiveAction: true,
                  trailingIcon: CupertinoIcons.delete,
                  child: const Text('Delete Slide'),
                ),
              ],
              enableHapticFeedback: true,
              child: SlideComposer(
                key: ValueKey(index),
                editingMode: editingMode,
                text: slideState.value[index].content,
                onTextChanged: (newText) => saveSlide(index, newText),
                slideLoaded: slideState.value[index].postId != null,
              ),
            ),
          );
        },
        loop: false,
        pagination: SwiperPagination(
          builder: DotSwiperPaginationBuilder(
            size: 9.0,
            activeSize: 9.0,
            activeColor: Styles.activeBlue,
            color: Styles.shadowGrey,
          ),
        ),
        controller: swiperController,
      ),
    );
  }
}

class SlideComposer extends StatelessWidget {
  const SlideComposer({
    super.key,
    required this.editingMode,
    required this.text,
    required this.onTextChanged,
    required this.slideLoaded,
  });

  final ValueNotifier<bool> editingMode;
  final String text;
  final Function(String) onTextChanged;
  final bool slideLoaded;

  @override
  Widget build(BuildContext context) {
    bool showTextField = editingMode.value && slideLoaded;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: Styles.paddingVertical,
        horizontal: Styles.paddingHorizontal,
      ),
      child: showTextField
          ? SlideTextField(
              initialText: text,
              editingMode: editingMode,
              onChanged: onTextChanged,
            )
          : GestureDetector(
              onTap: () {
                editingMode.value = true;
              },
              child: Text(text, style: Styles.comicSansText),
            ),
    );
  }
}

class SlideTextField extends HookWidget {
  const SlideTextField({
    super.key,
    required this.initialText,
    required this.editingMode,
    required this.onChanged,
  });

  final String initialText;
  final ValueNotifier<bool> editingMode;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: initialText);
    final focusNode = useFocusNode();

    return KeyboardActions(
      config: KeyboardActionsConfig(
        keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
        keyboardBarColor: CupertinoColors.lightBackgroundGray,
        actions: [
          KeyboardActionsItem(
            onTapAction: () {
              editingMode.value = false;
            },
            displayArrows: false,
            focusNode: focusNode,
          )
        ],
      ),
      child: CupertinoTextField.borderless(
        padding: const EdgeInsets.all(0.0),
        focusNode: focusNode,
        controller: controller,
        style: Styles.comicSansText,
        maxLines: 12,
        enableSuggestions: false,
        spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
        autocorrect: false,
        autofocus: true,
        onChanged: onChanged,
      ),
    );
  }
}
