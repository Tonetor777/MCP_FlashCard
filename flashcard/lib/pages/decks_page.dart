import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/add_deck_dialog.dart';
import '../widgets/edit_deck_dialog.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../models/deck.dart';
import '../services/firestore.dart';
import '../pages/deck_detail_page.dart';
import './signin.dart';

class DecksTab extends StatefulWidget {
  const DecksTab({Key? key}) : super(key: key);

  @override
  State<DecksTab> createState() => _DecksTabState();
}

class _DecksTabState extends State<DecksTab> {
  final FirestoreService _firestoreService = FirestoreService();
  final String _userId = FirebaseAuth.instance.currentUser!.uid;

  List<Deck> decks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  Future<void> _loadDecks() async {
    try {
      final loadedDecks = await _firestoreService.getDecks(_userId);
      setState(() {
        decks = loadedDecks;
        isLoading = false;
      });
    } catch (e) {
      // Handle error (e.g., show a snackbar)
      setState(() => isLoading = false);
    }
  }

  Future<void> _addDeck() async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => const AddDeckDialog(),
    );

    if (name != null && name.isNotEmpty) {
      final newDeck = Deck(
        id: DateTime.now().toString(),
        name: name,
        cards: [],
      );

      setState(() => decks.add(newDeck));
      await _firestoreService.addDeck(_userId, newDeck);
    }
  }

  Future<void> _editDeck(int index) async {
    final deck = decks[index];
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => EditDeckDialog(initialName: deck.name),
    );

    if (newName != null && newName.isNotEmpty && newName != deck.name) {
      final updatedDeck = Deck(
        id: deck.id,
        name: newName,
        cards: deck.cards,
      );

      setState(() => decks[index] = updatedDeck);
      await _firestoreService.updateDeck(_userId, updatedDeck);
    }
  }

  Future<void> _deleteDeck(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        itemName: decks[index].name,
      ),
    );

    if (confirmed == true) {
      final deletedDeckId = decks[index].id;

      setState(() => decks.removeAt(index));
      await _firestoreService.deleteDeck(_userId, deletedDeckId);
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SignIn(),
      ),
    ); // Redirect to login page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flash Card',
          style: TextStyle(
            color: Colors.white, // White color
            fontWeight: FontWeight.bold, // Bold text
          ),
        ),
        backgroundColor: const Color(0xFFA561FB),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white, // White color for the icon
            ),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : decks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.library_books,
                        size: 64,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text('No Decks Yet'),
                      const SizedBox(height: 8),
                      const Text('Create your first deck to get started!'),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: decks.length,
                  itemBuilder: (context, index) {
                    final deck = decks[index];
                    final cardCount = deck.cards.length;

                    return Card(
                      elevation: 2,
                      child: InkWell(
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DeckDetailScreen(
                                deck: deck,
                              ),
                            ),
                          );
                          await _loadDecks();
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Header with Card Count and Menu
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                PopupMenuButton<String>(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.more_vert, size: 20),
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _editDeck(index);
                                    } else if (value == 'delete') {
                                      _deleteDeck(index);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 20),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, size: 20),
                                          SizedBox(width: 8),
                                          Text('Delete'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Expanded(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    deck.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Playfair Display',
                                        ),
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDeck,
        icon: const Icon(Icons.add),
        label: const Text('New Deck'),
      ),
    );
  }
}
