import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';

class RecipesService {
  final _recipesRef = FirebaseFirestore.instance.collection('recipes');
  final _productsRef = FirebaseFirestore.instance.collection('products');

  /// Crear o actualizar receta
  Future<void> saveRecipe(RecipeModel recipeModel) async {
    await _recipesRef.doc(recipeModel.productId).set(recipeModel.toMap()/*, SetOptions(merge: true)*/);

    /// ACTUALIZAR COSTO Y GANANCIA DEL PRODUCTO
    final productDoc = _productsRef.doc(recipeModel.productId);

    final productSnap = await productDoc.get();
    if (!productSnap.exists) return;

    final priceUsd = (productSnap['priceUsd'] ?? 0).toDouble();
    final costUsd = recipeModel.totalCost;
    final profitUsd = priceUsd - costUsd;

    await productDoc.update({
      'costUsd': costUsd,
      'profitUsd': profitUsd,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Obtener receta por producto
  Stream<RecipeModel?> getRecipeByProduct(String productId) {
    return _recipesRef.doc(productId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return RecipeModel.fromMap(doc.id, doc.data()!);
    });
  }

  /// Eliminar receta
  Future<void> deleteRecipe(String productId) async {
    await _recipesRef.doc(productId).delete();
  }
}
