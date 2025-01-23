import 'package:cloud_firestore/cloud_firestore.dart';
import './flashcard.dart';

class Deck {
  final String id;
  final String name;
  final List<FlashCard> cards;

  Deck({required this.id, required this.name, required this.cards});

  factory Deck.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    List<FlashCard> flashCards = [];
    if (data['cards'] != null) {
      flashCards = (data['cards'] as List<dynamic>)
          .map((card) => FlashCard.fromMap(card))
          .toList();
    }
    return Deck(
      id: doc.id,
      name: data['name'],
      cards: flashCards,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'cards': cards.map((flashCard) => flashCard.toMap()).toList(),
    };
  }
}
