import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:wordbridge/screens/home.dart';
import 'package:wordbridge/screens/providers/provider.dart';

class AdminHome extends StatefulWidget {
  AdminHome({super.key, required this.userId});
  final String userId;

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final wordController = TextEditingController();
  final searchController = TextEditingController();
  final animationLinkController = TextEditingController();
  List<DocumentSnapshot> allWords = [];
  List<DocumentSnapshot> toFilter = [];
  String languageValue = 'English';
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    searchController.addListener(toSearch);
  }

  void toSearch() {
    String query = searchController.text.toLowerCase();
    setState(
      () {
        toFilter = allWords
            .where((doc) => doc['word'].toLowerCase().contains(query))
            .where((doc) => doc['language'] == languageValue)
            .toList();
      },
    );
  }

  void logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => AppMainScreen()));
    } on FirebaseException catch (ex) {
      print(ex.code);
    }
  }

  void addWord(BuildContext context, String word, String link) async {
    final collectionWords = FirebaseFirestore.instance.collection('admin');
    String formattedWord = word[0].toUpperCase() + word.substring(1);
    final querySnapshot =
        await collectionWords.where('word', isEqualTo: formattedWord).get();

    if (querySnapshot.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Word: "$formattedWord" already exists.')),
      );
      return;
    }

    String directLink = convertDriveLink(link);

    await collectionWords.add({
      'word': formattedWord,
      'language': languageValue,
      'link': directLink,
    }).then(
      (value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Word: $formattedWord Added')),
        );
      },
    );
  }

  String convertDriveLink(String driveLink) {
    Uri uri = Uri.parse(driveLink);
    String? fileId = uri.pathSegments.length > 2 ? uri.pathSegments[2] : null;

    if (fileId != null) {
      return "https://drive.google.com/uc?export=view&id=$fileId";
    } else {
      return driveLink;
    }
  }

  Future<void> toEdit(BuildContext context, String docId, String currentWord,
      String currentLanguage) async {
    TextEditingController wordController =
        TextEditingController(text: currentWord);
    String selectedLanguage = currentLanguage;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Word'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: currentWord,
                decoration: InputDecoration(labelText: 'Current Word'),
                readOnly: true,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: wordController,
                decoration: InputDecoration(labelText: 'New Word'),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedLanguage,
                decoration: InputDecoration(labelText: 'Select Language'),
                items: [
                  'English',
                  'Filipino',
                ]
                    .map((lang) => DropdownMenuItem(
                          value: lang,
                          child: Text(lang),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedLanguage = value;
                  }
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Animation Link'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String newWord = wordController.text.trim();

                if (newWord.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Must not be empty!'),
                    ),
                  );
                  return;
                }

                final collectionRef =
                    FirebaseFirestore.instance.collection('admin');
                final querySnapshot = await collectionRef
                    .where('word',
                        isEqualTo:
                            newWord[0].toUpperCase() + newWord.substring(1))
                    .limit(1)
                    .get();

                if (querySnapshot.docs.isNotEmpty &&
                    querySnapshot.docs.first.id != docId) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('This word already exists!'),
                    ),
                  );
                  return;
                }
                await collectionRef.doc(docId).update({
                  'word': newWord,
                  'language': selectedLanguage,
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Word updated!'),
                  ),
                );
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showAdd(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: wordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text('Word'),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Language: '),
                    DropdownButton<String>(
                      padding: EdgeInsets.all(12),
                      value: languageValue,
                      onChanged: (String? newValue) {
                        setState(() {
                          languageValue = newValue!;
                        });
                      },
                      items: const [
                        DropdownMenuItem<String>(
                          value: 'English',
                          child: Text('English'),
                        ),
                        DropdownMenuItem(
                          value: 'Filipino',
                          child: Text('Filipino'),
                        )
                      ],
                    ),
                  ],
                ),
                TextFormField(
                  controller: animationLinkController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text('Animation Link'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    child: const Text('Add'),
                    onPressed: () {
                      addWord(context, wordController.text,
                          animationLinkController.text);
                      wordController.clear();
                    },
                  ),
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  Future<void> showLogout(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Do you want to logout?'),
          content: SingleChildScrollView(),
          actions: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    child: const Text('Yes'),
                    onPressed: () {
                      logout(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Logged-Out Successfully.'),
                        ),
                      );
                    },
                  ),
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  void toDelete(BuildContext context, String docId) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this word?'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text('Yes'),
                ),
              ],
            ),
          ],
        );
      },
    );
    if (confirmDelete == true) {
      try {
        await firebaseFirestore.collection('admin').doc(docId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Word Deleted'),
          ),
        );
      } on FirebaseAuthException catch (ex) {
        print(ex);
        return;
      }
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepPurple,
        title: Text(
          'Admin',
          style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showLogout(context);
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Consumer<MainProvider>(
        builder: (context, provider, child) => Column(
          children: [
            Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: "Search",
                        labelStyle: TextStyle(
                            color: Colors.deepPurpleAccent, fontSize: 16),
                        hintText: "Type to search...",
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon:
                            Icon(Icons.search, color: Colors.deepPurpleAccent),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Colors.deepPurpleAccent, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.deepPurple, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.deepPurple, width: 1),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('admin').snapshots(),
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

                  List<DocumentSnapshot> filteredWords = allWords.where(
                    (doc) {
                      String word =
                          (doc['word'] ?? '').toString().toLowerCase();
                      String query = searchController.text.toLowerCase().trim();
                      if (query.isEmpty) return true;
                      return word.contains(query);
                    },
                  ).toList();
                  List<DocumentSnapshot> wordsToDisplay = provider.showFavorites
                      ? allWords
                          .where(
                            (doc) => provider.isFavorite(
                              doc['word'],
                            ),
                          )
                          .toList()
                      : filteredWords;
                  return wordsToDisplay.isEmpty
                      ? Center(
                          child: Text('No Data...'),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(16),
                          child: ListView.builder(
                            itemCount: wordsToDisplay.length,
                            itemBuilder: (context, index) {
                              var word = wordsToDisplay[index]['word'];
                              var languageName =
                                  wordsToDisplay[index]['language'];

                              return GestureDetector(
                                onTap: () {
                                  provider.selectWord(word, languageName);
                                },
                                child: Card(
                                  color: Colors.blueGrey[50],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                      color: Colors.deepPurple,
                                      width: 2,
                                    ),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(16),
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.label,
                                        color: Colors.deepPurpleAccent,
                                        size: 33,
                                      ),
                                      title: Text(
                                        word,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Language: $languageName',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              toEdit(
                                                  context,
                                                  wordsToDisplay[index].id,
                                                  word,
                                                  languageName);
                                            },
                                            icon: Icon(Icons.edit,
                                                color: Colors.blueGrey[800]),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              toDelete(context,
                                                  wordsToDisplay[index].id);
                                            },
                                            icon: Icon(Icons.delete,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAdd(context);
        },
        backgroundColor: Colors.deepPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 6,
        child: Icon(
          Icons.add,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }
}
