import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/deck.dart';
import '../widgets/add_card_dialog.dart';
import '../widgets/edit_card_dialog.dart';
import '../widgets/delete_confirmation_dialog.dart';

class DeckDetailScreen extends StatefulWidget {
  final Deck deck;

  const DeckDetailScreen({
    required this.deck,
    super.key,
  });

  @override
  State<DeckDetailScreen> createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends State<DeckDetailScreen> {
  late CollectionReference cardsCollection;

  @override
  void initState() {
    super.initState();
    cardsCollection =
        FirebaseFirestore.instance.collection('decks').doc(widget.deck.id).collection('cards');
  }

  Future<void> _addCard() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const AddCardDialog(),
    );
    if (result != null) {
      await cardsCollection.add({
        'question': result['question']!,
        'answer': result['answer']!,
      });
    }
  }

  Future<void> _editCard(String cardId, String currentQuestion, String currentAnswer) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => EditCardDialog(
        initialQuestion: currentQuestion,
        initialAnswer: currentAnswer,
      ),
    );
    if (result != null) {
      await cardsCollection.doc(cardId).update({
        'question': result['question']!,
        'answer': result['answer']!,
      });
    }
  }

  Future<void> _deleteCard(String cardId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        itemName: 'this card',
      ),
    );
    if (confirmed == true) {
      await cardsCollection.doc(cardId).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.library_books,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.deck.name,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: cardsCollection.snapshots(),
                  builder: (context, snapshot) {
                    final cardCount = snapshot.data?.size ?? 0;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$cardCount cards',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap a card to see details',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    );
                  },
                ),
                TextButton.icon(
                  onPressed: _addCard,
                  icon: const Icon(
                    Icons.add_circle,
                    size: 28,
                  ),
                  label: const Text(
                    'Add Card',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: cardsCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_add,
                          size: 64,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No cards yet',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first flashcard to get started',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color:
                                    Theme.of(context).textTheme.bodySmall?.color,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                final cards = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    final cardDoc = cards[index];
                    final cardData = cardDoc.data() as Map<String, dynamic>;
                    final question = cardData['question'] as String;
                    final answer = cardData['answer'] as String;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      elevation: 1,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          title: Text(
                            question,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          children: [
                            Container(
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                bottom: 16,
                              ),
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Answer:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    answer,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () => _editCard(
                                          cardDoc.id,
                                          question,
                                          answer,
                                        ),
                                        icon: const Icon(Icons.edit, size: 20),
                                        label: const Text('Edit'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      TextButton.icon(
                                        onPressed: () =>
                                            _deleteCard(cardDoc.id),
                                        icon: const Icon(Icons.delete, size: 20),
                                        label: const Text('Delete'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
