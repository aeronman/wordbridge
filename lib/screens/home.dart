import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wordbridge/screens/admin_login.dart';
import 'package:wordbridge/screens/providers/provider.dart';

class AppMainScreen extends StatelessWidget {
  AppMainScreen({super.key});

  // void textSpeech(BuildContext context) async {
  //   final provider = Provider.of<MainProvider>(context, listen: false);
  //   String word = provider.selectedWord;
  //   String language = provider.languageName;

  //   if (word.isEmpty) {
  //     flutterTts.speak('No word selected');
  //     return;
  //   }

  //   print('Speaking: $word');
  //   print('Speaking Language: $language');

  //   if (language == 'English') {
  //     await flutterTts.setLanguage('en-US');
  //   } else if (language == 'Filipino') {
  //     await flutterTts.setLanguage('fil-PH');
  //   } else {
  //     await flutterTts.setLanguage('en-US');
  //   }

  //   flutterTts.setPitch(1.0);
  //   flutterTts.setSpeechRate(0.4);
  //   await flutterTts.speak(word);
  // }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Hello User'),
        backgroundColor: Colors.deepPurple,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_circle, size: 50, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Welcome',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: Icon(Icons.home, color: Colors.deepPurpleAccent),
                    title: Text('Home'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  // ListTile(
                  //   leading:
                  //       Icon(Icons.settings, color: Colors.deepPurpleAccent),
                  //   title: Text('Settings'),
                  //   onTap: () {
                  //   },
                  // ),
                  // Divider(),
                  // ListTile(
                  //   leading: Icon(Icons.logout, color: Colors.redAccent),
                  //   title: Text('Logout',
                  //       style: TextStyle(color: Colors.redAccent)),
                  //   onTap: () {
                  //   },
                  // ),
                ],
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child: ElevatedButton.icon(
            //     onPressed: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(builder: (_) => AdminLogin()),
            //       );
            //     },
            //     icon: Icon(Icons.admin_panel_settings, color: Colors.white),
            //     label: Text(
            //       'Admin Login',
            //       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            //     ),
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Colors.deepPurpleAccent,
            //       foregroundColor: Colors.white,
            //       padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
      body: Consumer<MainProvider>(
        builder: (context, provider, child) => Padding(
          padding: const EdgeInsets.all(14),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: provider.searchController,
                        onChanged: (text) {
                          provider.searchWords(text);
                        },
                        decoration: InputDecoration(
                          labelText: "Search",
                          labelStyle: TextStyle(
                            color: Colors.deepPurpleAccent,
                            fontSize: 16,
                          ),
                          hintText: "Type a word...",
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.deepPurpleAccent,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              provider.speechEnabled
                                  ? provider.stopListening()
                                  : provider.startListening();
                            },
                            icon: Icon(
                              provider.speechEnabled
                                  ? Icons.mic_external_on
                                  : Icons.mic_external_off,
                              color: provider.speechEnabled
                                  ? Colors.red
                                  : Colors.deepPurple,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.deepPurpleAccent,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.deepPurple,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade400,
                              width: 1,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 14, horizontal: 16),
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => provider.clearSelectedWords(),
                            child: Text(
                              provider.selectedWord.isEmpty
                                  ? 'Selected Word: None'
                                  : 'Selected Word: ${provider.selectedWord}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Switch(
                            value: provider.showFavorites,
                            padding: EdgeInsets.all(10),
                            activeColor: Colors.redAccent,
                            inactiveThumbColor: Colors.grey,
                            onChanged: (value) {
                              provider.toggleShowFavorites();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('admin')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          !snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No data found.'));
                      }
                      List<DocumentSnapshot> allWords = snapshot.data!.docs;

                      List<DocumentSnapshot> filteredWords =
                          allWords.where((doc) {
                        String word =
                            (doc['word'] ?? '').toString().toLowerCase();
                        String query =
                            provider.searchController.text.toLowerCase().trim();

                        if (query.isEmpty) return true;
                        return word.contains(query);
                      }).toList();
                      List<DocumentSnapshot> wordsToDisplay = provider
                              .showFavorites
                          ? allWords
                              .where((doc) => provider.isFavorite(doc['word']))
                              .toList()
                          : filteredWords;
                      return wordsToDisplay.isEmpty
                          ? Center(
                              child: Text('No Data...'),
                            )
                          : ListView.builder(
                              itemCount: wordsToDisplay.length,
                              itemBuilder: (context, index) {
                                var word = wordsToDisplay[index]['word'];
                                var languageName =
                                    wordsToDisplay[index]['language'];
                                bool isFavorite = provider.isFavorite(word);

                                return GestureDetector(
                                  onTap: () {
                                    provider.selectWord(word, languageName);
                                  },
                                  child: Card(
                                    child: ListTile(
                                      leading: FaIcon(FontAwesomeIcons.book,
                                          color: Colors.deepPurpleAccent),
                                      title: Text(
                                        word,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic),
                                      ),
                                      subtitle: Text('Language: $languageName',
                                          style: TextStyle(fontSize: 13)),
                                      trailing: IconButton(
                                        onPressed: () {
                                          provider.toggleFavorite(word);
                                        },
                                        icon: Icon(
                                          isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isFavorite
                                              ? Colors.red
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // ElevatedButton(
                      //   onPressed: () => provider.showSignLanguage(
                      //       context, provider.selectedWord),
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.deepPurpleAccent,
                      //     foregroundColor: Colors.white,
                      //     padding: EdgeInsets.symmetric(
                      //         horizontal: 34, vertical: 22),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(12),
                      //     ),
                      //   ),
                      //   child: Text('Reveal Sign Language.',
                      //       style: TextStyle(
                      //           fontSize: 20, fontWeight: FontWeight.bold)),
                      // ),

                      // ElevatedButton(
                      //   onPressed: () => textSpeech(context),
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.orange,
                      //     foregroundColor: Colors.white,
                      //     padding: EdgeInsets.symmetric(
                      //         horizontal: 24, vertical: 12),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(12),
                      //     ),
                      //   ),
                      //   child: Text('Mute',
                      //       style: TextStyle(
                      //           fontSize: 16, fontWeight: FontWeight.bold)),
                      // ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        provider.showSignLanguage(context, provider.selectedWord);
      },
      child: FaIcon(FontAwesomeIcons.signLanguage),
      ),
    );
  }
}
