import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  DocumentReference<Map<String, dynamic>>? get userDoc {
    final user = currentUser;
    if (user == null) return null;

    return _firestore.collection('users').doc(user.uid);
  }

  Future<void> ensureUserProfileExists() async {
    final user = currentUser;
    final doc = userDoc;

    if (user == null || doc == null) return;

    final snapshot = await doc.get();

    if (!snapshot.exists) {
      await doc.set({
        'email': user.email ?? '',
        'gold': 0,
        'xp': 0,
        'badges': 0,
        'completedAdventures': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<int> getCurrentGold() async {
    final doc = userDoc;
    if (doc == null) return 0;

    await ensureUserProfileExists();

    final snapshot = await doc.get();
    final data = snapshot.data();

    return data?['gold'] ?? 0;
  }

  Stream<Map<String, dynamic>> watchUserProfile() {
    final doc = userDoc;

    if (doc == null) {
      return const Stream.empty();
    }

    return doc.snapshots().map((snapshot) {
      final data = snapshot.data();

      if (data == null) {
        return {
          'email': currentUser?.email ?? '',
          'gold': 0,
          'xp': 0,
          'badges': 0,
          'completedAdventures': 0,
        };
      }

      return data;
    });
  }

  Future<void> addReward({
    required int gold,
    required int xp,
  }) async {
    final doc = userDoc;
    if (doc == null) return;

    await ensureUserProfileExists();

    await doc.update({
      'gold': FieldValue.increment(gold),
      'xp': FieldValue.increment(xp),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> spendProfileGold(int amount) async {
    final doc = userDoc;
    if (doc == null) return false;

    await ensureUserProfileExists();

    final snapshot = await doc.get();
    final data = snapshot.data();

    final currentGold = data?['gold'] ?? 0;

    if (currentGold < amount) {
      return false;
    }

    await doc.update({
      'gold': FieldValue.increment(-amount),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return true;
  }

  Future<void> addBadge() async {
    final doc = userDoc;
    if (doc == null) return;

    await ensureUserProfileExists();

    await doc.update({
      'badges': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> saveAdventureHistory({
    required String field,
    required String topic,
    required String level,
    required String mode,
    required String mapTitle,
    required int earnedGold,
    required int earnedXp,
  }) async {
    final doc = userDoc;
    if (doc == null) return;

    await ensureUserProfileExists();

    await doc.collection('history').add({
      'field': field,
      'topic': topic,
      'level': level,
      'mode': mode,
      'mapTitle': mapTitle,
      'earnedGold': earnedGold,
      'earnedXp': earnedXp,
      'completedAt': FieldValue.serverTimestamp(),
    });

    await doc.update({
      'completedAdventures': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchHistory() {
    final doc = userDoc;

    if (doc == null) {
      return const Stream.empty();
    }

    return doc
        .collection('history')
        .orderBy('completedAt', descending: true)
        .snapshots();
  }
}