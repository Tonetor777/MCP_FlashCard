import 'package:cloud_firestore/cloud_firestore.dart';

class FlashCard {
  final String question;
  final String answer;

  FlashCard({required this.question, required this.answer});

  factory FlashCard.fromMap(Map<String, dynamic> map) {
    return FlashCard(
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
    };
  }
}
