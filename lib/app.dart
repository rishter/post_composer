import 'styles.dart';
import 'image_util.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/cupertino.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:card_swiper/card_swiper.dart';

/*
backlog: 
  * persist data? 
    * seperate named posts in a list?
  * what's the deal with the image?
  * backlog
    * hide delete when there is only one slide?
*/

class PostComposerApp extends StatelessWidget {
  const PostComposerApp({super.key}) : super();

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      theme: CupertinoThemeData(
        textTheme: CupertinoTextThemeData(
          navLargeTitleTextStyle: TextStyle(fontSize: 25.0),
        ),
      ),
      home: PostComposerHomePage(),
    );
  }
}

class PostComposerHomePage extends HookWidget {
  const PostComposerHomePage({super.key}) : super();

  @override
  Widget build(BuildContext context) {
    final editingMode = useState(false);
    final postCount = useState(1);
    final imageKeys = useState<List<GlobalKey>>([GlobalKey()]);
    final postContents = useState<List<String>>([""]);

    final swiperController = useMemoized(() => SwiperController(), []);

    canAddNewSlide() => postCount.value < 10;
    canRemoveSlide() => postCount.value > 1;

    void addSlide() {
      if (!canAddNewSlide()) return;

      final oldCount = postCount.value;
      editingMode.value = false;
      postCount.value += 1;
      final newContents = List<String>.from(postContents.value);
      newContents.add("");
      postContents.value = newContents;

      final newImageKeys = List<GlobalKey>.from(imageKeys.value);
      newImageKeys.add(GlobalKey());
      imageKeys.value = newImageKeys;

      swiperController.move(oldCount);
    }

    void removeSlide(index) {
      if (!canRemoveSlide()) return;
      swiperController.previous();

      final oldCount = postCount.value;
      editingMode.value = false;
      postCount.value -= 1;

      final newContents = List<String>.from(postContents.value);
      newContents.removeAt(index);
      postContents.value = newContents;

      final newImageKeys = List<GlobalKey>.from(imageKeys.value);
      newImageKeys.removeAt(index);
      imageKeys.value = newImageKeys;

      swiperController.move(oldCount);
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
        middle: const Text('Post Composer'),
        trailing: CupertinoButton(
          padding: const EdgeInsets.all(0.0),
          onPressed: canAddNewSlide() ? addSlide : null,
          child: const Text('New Slide'),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: PostSwiper(
                  swiperController: swiperController,
                  editingMode: editingMode,
                  postCount: postCount.value,
                  imageKeys: imageKeys.value,
                  postContents: postContents,
                  removeSlide: removeSlide,
                ),
              ),
            ),
            CupertinoButton(
              onPressed: editingMode.value ? null : captureAndSaveImages,
              child: Text(
                  postCount.value > 1 ? 'Download Images' : 'Download Image'),
            ),
          ],
        ),
      ),
    );
  }
}

class PostSwiper extends HookWidget {
  const PostSwiper({
    super.key,
    required this.swiperController,
    required this.editingMode,
    required this.postCount,
    required this.imageKeys,
    required this.postContents,
    required this.removeSlide,
    this.captureMode = false,
  }) : super();

  final SwiperController swiperController;
  final ValueNotifier<bool> editingMode;
  final int postCount;
  final List<GlobalKey> imageKeys;
  final ValueNotifier<List<String>> postContents;
  final Function removeSlide;
  final bool captureMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 360,
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
        itemCount: postCount,
        itemBuilder: (BuildContext context, int index) {
          return RepaintBoundary(
            key: imageKeys[index],
            child: CupertinoContextMenu(
              actions: [
                CupertinoContextMenuAction(
                  onPressed: () {
                    Navigator.pop(context);
                    removeSlide(index);
                  },
                  isDestructiveAction: true,
                  trailingIcon: CupertinoIcons.delete,
                  child: const Text('Delete Slide'),
                )
              ],
              enableHapticFeedback: true,
              child: PostContent(
                key: ValueKey(index),
                editingMode: editingMode,
                text: postContents.value[index],
                onTextChanged: (newText) {
                  final newContents = List<String>.from(postContents.value);
                  newContents[index] = newText;
                  postContents.value = newContents;
                },
              ),
            ),
          );
        },
        loop: false,
        pagination: SwiperPagination(
          builder: DotSwiperPaginationBuilder(
            activeColor: Styles.activeBlue,
            color: Styles.shadowGrey,
          ),
        ),
        controller: swiperController,
      ),
    );
  }
}

class PostContent extends HookWidget {
  const PostContent({
    super.key,
    required this.editingMode,
    required this.text,
    required this.onTextChanged,
  });

  final ValueNotifier<bool> editingMode;
  final String text;
  final Function(String) onTextChanged;

  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController(text: text);
    final focusNode = useFocusNode();

    useEffect(() {
      textController.addListener(() {
        onTextChanged(textController.text);
      });
      return null;
    }, [textController]);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 22.0),
      child: editingMode.value
          ? PostTextField(
              controller: textController,
              editingMode: editingMode,
              focusNode: focusNode)
          : GestureDetector(
              onTap: () {
                editingMode.value = true;
              },
              child: Text(text, style: Styles.comicSansText),
            ),
    );
  }
}

class PostTextField extends StatelessWidget {
  const PostTextField({
    super.key,
    required this.controller,
    required this.editingMode,
    required this.focusNode,
  });

  final TextEditingController controller;
  final ValueNotifier<bool> editingMode;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
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
      ),
    );
  }
}
