import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/deck.dart';
import '../models/flashcard.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Deck>> getDecks(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('decks')
        .get();

    List<Future<Deck>> deckFutures = snapshot.docs.map((doc) async {
      final deckData = doc.data();
      final deckId = doc.id; // Assuming the document ID represents the deck ID

      // Fetch the cards inside this deck
      final cardsSnapshot = await _firestore
          .collection('decks')
          .doc(deckId)
          .collection('cards')
          .get();

      List<FlashCard> cards = cardsSnapshot.docs.map((cardDoc) {
        return FlashCard(
          question: cardDoc['question'],
          answer: cardDoc['answer'],
        );
      }).toList();

      return Deck(
        id: doc.id,
        name: deckData['name'],
        cards: cards,
      );
    }).toList();

    // Wait for all Futures to resolve and return the list
    return Future.wait(deckFutures);
  }

  Future<void> addDeck(String userId, Deck deck) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('decks')
        .doc(deck.id)
        .set(deck.toFirestore());
  }

  Future<void> updateDeck(String userId, Deck deck) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('decks')
        .doc(deck.id)
        .update(deck.toFirestore());
  }

  Future<void> deleteDeck(String userId, String deckId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('decks')
        .doc(deckId)
        .delete();
  }
}
