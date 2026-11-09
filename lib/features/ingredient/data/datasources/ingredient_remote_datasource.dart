import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ingredient_model.dart';

abstract class IngredientRemoteDataSource {
  Future<List<IngredientModel>> getAllIngredients();
  /// Obtiene un ingrediente específico por su ID
  Future<IngredientModel?> getIngredientById(String ingredientId);
  Future<void> createIngredient(IngredientModel ingredient);
  Future<void> updateIngredient(IngredientModel ingredient);
  Future<void> deleteIngredient(String ingredientId);
}

class IngredientRemoteDataSourceImpl implements IngredientRemoteDataSource {
  final FirebaseFirestore _firestore;

  IngredientRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  String get _collection => 'ingredients';

  @override
  Future<List<IngredientModel>> getAllIngredients() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs
        .map((doc) => IngredientModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<IngredientModel?> getIngredientById(String ingredientId) async {
    final doc = await _firestore
        .collection(_collection)
        .doc(ingredientId)
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return IngredientModel.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<void> createIngredient(IngredientModel ingredient) async {
    await _firestore
        .collection(_collection)
        .doc(ingredient.id.isNotEmpty ? ingredient.id : null)
        .set(ingredient.toMap());
  }

  @override
  Future<void> updateIngredient(IngredientModel ingredient) async {
    await _firestore
        .collection(_collection)
        .doc(ingredient.id)
        .update(ingredient.toMap());
  }

  @override
  Future<void> deleteIngredient(String ingredientId) async {
    await _firestore.collection(_collection).doc(ingredientId).delete();
  }
}
