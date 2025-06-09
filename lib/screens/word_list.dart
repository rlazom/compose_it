import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'game_screen.dart';

class WordListScreen extends StatelessWidget {
  WordListScreen({super.key});

  final TextEditingController wordCtrl = TextEditingController();
  final TextEditingController emojiCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      // appBar: AppBar(title: const Text('Elige una Palabra')),
      // appBar: AppBar(title: const Text('Compose It')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 64.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(child: FittedBox(child: Text('Componedor', style: TextStyle(fontWeight: FontWeight.bold),))),
              ],
            ),
            SizedBox(height: 64,),
            TextField(
              maxLength: 16,
              controller: wordCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                label: Text('Palabra'),
              ),
              onChanged: (String val) {
                wordCtrl.text = val.toUpperCase().trim();
              },
            ),
            SizedBox(height: 32,),

            TextField(
              controller: emojiCtrl,
              decoration: InputDecoration(
                  label: Text('Imagen (Emoji)')
              ),
            ),
            EmojiPicker(
              // textEditingController: emojiCtrl,
              onEmojiSelected: (category, Emoji emoji) {
                emojiCtrl.text = emoji.emoji;
              },
              onBackspacePressed: () => emojiCtrl.clear(),
              config: Config(
                height: 256,
                emojiTextStyle: TextStyle(fontSize: 32),
                checkPlatformCompatibility: true,
                emojiViewConfig: EmojiViewConfig(
                  columns: 6,
                  // Issue: https://github.com/flutter/flutter/issues/28894
                  emojiSizeMax: 64,
                ),
                viewOrderConfig: const ViewOrderConfig(
                  top: EmojiPickerItem.categoryBar,
                  middle: EmojiPickerItem.emojiView,
                  bottom: EmojiPickerItem.searchBar,
                ),
                skinToneConfig: const SkinToneConfig(),
                categoryViewConfig: const CategoryViewConfig(),
                bottomActionBarConfig: const BottomActionBarConfig(),
                searchViewConfig: const SearchViewConfig(),
              ),
              // config: Config(/* ...*/),
              // customWidget: (config, state, showSearchView) => CustomView(
              //   config,
              //   state,
              //   showSearchView,
              // ),
            ),

            SizedBox(height: 64,),

            FilledButton(
              onPressed: () async {
                if (wordCtrl.text.isNotEmpty) {

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => GameScreen(
                        word: wordCtrl.text.trim(),
                        emoji: emojiCtrl.text.trim(),
                      ),
                    ),
                  );

                  wordCtrl.clear();
                  emojiCtrl.clear();
                }

              },
              child: Text('Comenzar'),
            ),

          ],
        ),
      ),
      // body: GridView.builder(
      //   padding: const EdgeInsets.all(16),
      //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      //     crossAxisCount: 2,
      //     childAspectRatio: 1.2,
      //   ),
      //   itemCount: words.length,
      //   itemBuilder: (context, index) => Card(
      //     child: InkWell(
      //       onTap: () => Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //           builder: (ctx) => GameScreen(word: words[index]),
      //         ),
      //       ),
      //       child: Column(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: [
      //           Image.asset(words[index].imagePath, height: 80),
      //           const SizedBox(height: 10),
      //           Text(
      //             words[index].word,
      //             style: const TextStyle(fontSize: 24),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}