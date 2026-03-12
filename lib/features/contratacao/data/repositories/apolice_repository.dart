import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/apolice_model.dart';

/// Repository for managing insurance policies (Apólices) in Firestore.
///
/// Uses the `apolices` root collection with `.withConverter()` for type safety.
class ApoliceRepository {
  final FirebaseFirestore _firestore;

  ApoliceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Reference to the `apolices` collection with type-safe converter.
  CollectionReference<ApoliceModel> get _collection =>
      _firestore.collection('apolices').withConverter<ApoliceModel>(
            fromFirestore: (snapshot, _) =>
                ApoliceModel.fromFirestore(snapshot),
            toFirestore: (model, _) => model.toFirestore(),
          );

  /// Creates a new apólice and returns the generated document ID.
  Future<String> createApolice(ApoliceModel apolice) async {
    final docRef = await _collection.add(apolice);
    return docRef.id;
  }

  /// Gets a single apólice by its document ID.
  Future<ApoliceModel?> getApolice(String id) async {
    final doc = await _collection.doc(id).get();
    return doc.data();
  }

  /// Streams all apólices for a given user, ordered by creation date.
  Stream<List<ApoliceModel>> getApolicesByUser(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Streams only active apólices for a given user.
  Stream<List<ApoliceModel>> getActiveApolicesByUser(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'activa')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Updates the status of an apólice (e.g. pendente → activa).
  Future<void> updateStatus(String apoliceId, String newStatus) async {
    await _collection.doc(apoliceId).update({
      'status': newStatus,
    } as Map<String, Object?>);
  }

  /// Updates payment details after a successful transaction.
  Future<void> updatePayment({
    required String apoliceId,
    required String transactionId,
    required String pagamentoStatus,
  }) async {
    await _collection.doc(apoliceId).update({
      'transactionId': transactionId,
      'pagamentoStatus': pagamentoStatus,
      if (pagamentoStatus == 'confirmado') 'status': 'activa',
      if (pagamentoStatus == 'confirmado')
        'dataInicio': Timestamp.fromDate(DateTime.now()),
      if (pagamentoStatus == 'confirmado')
        'dataFim': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 365)),
        ),
    } as Map<String, Object?>);
  }

  /// Generates the next sequential apólice number.
  ///
  /// Format: `INDICO-{YEAR}-{SEQUENTIAL_NUMBER}`
  /// e.g. `INDICO-2024-00042`
  Future<String> getNextApoliceNumber() async {
    final year = DateTime.now().year;
    final prefix = 'INDICO-$year-';

    final snapshot = await _firestore
        .collection('apolices')
        .where('numero', isGreaterThanOrEqualTo: prefix)
        .where('numero', isLessThan: '${prefix}z')
        .orderBy('numero', descending: true)
        .limit(1)
        .get();

    int nextNumber = 1;
    if (snapshot.docs.isNotEmpty) {
      final lastNumero = snapshot.docs.first.data()['numero'] as String? ?? '';
      final lastNumberStr = lastNumero.replaceFirst(prefix, '');
      nextNumber = (int.tryParse(lastNumberStr) ?? 0) + 1;
    }

    return '$prefix${nextNumber.toString().padLeft(5, '0')}';
  }
}
