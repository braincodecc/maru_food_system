import '../../domain/entities/user_role.enum.dart';
import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';

/// Contrato para las peticiones externas (API / Firebase / Backend)
abstract class IdentityRemoteDataSource {
  /// Obtiene el usuario autenticado actualmente desde Firebase Auth y Firestore
  Future<UserModel?> getCurrentUser();

  /// Revalida el token y el rol actual del usuario directamente con el servidor de Firebase
  Future<UserModel?> checkRoleAccess();

  /// Inicia sesión con correo y contraseña en Firebase Auth y obtiene su perfil de Firestore
  Future<UserModel?> login(String email, String password);

  /// Cierra la sesión activa en Firebase Auth
  Future<void> logout();
} 

/// Implementación real usando por ejemplo Firebase Auth o un cliente HTTP (Dio)
class IdentityRemoteDataSourceImpl implements IdentityRemoteDataSource {
  final auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  IdentityRemoteDataSourceImpl({
    auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      return null;
    }

    return await _fetchUserDataFromFirestore(firebaseUser.uid, firebaseUser.email ?? '');
  }

  @override
  Future<UserModel?> checkRoleAccess() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    // Forzamos la actualización del token
    await firebaseUser.getIdToken(true);

    return await _fetchUserDataFromFirestore(firebaseUser.uid, firebaseUser.email ?? '');
  }

  @override
  Future<UserModel?> login(String email, String password) async {
    try {
      // 1. Autenticar con correo y contraseña en Firebase Auth
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Error al autenticar: Usuario no encontrado.');
      }

      // 2. Obtener la información del usuario y su rol desde Firestore
      final userModel = await _fetchUserDataFromFirestore(
        firebaseUser.uid,
        firebaseUser.email ?? email,
      );

      if (userModel == null) {
        throw Exception('No se encontró la información del perfil del usuario.');
      }

      return userModel;
    } on auth.FirebaseAuthException catch (e) {
      // Manejo de errores típicos de Firebase Auth
      throw Exception(_mapFirebaseAuthError(e.code));
    } catch (e) {
      throw Exception('Ocurrió un error inesperado al iniciar sesión.');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar la sesión en el servidor.');
    }
  }

  /// Método auxiliar privado para buscar el documento del usuario en Firestore
  Future<UserModel?> _fetchUserDataFromFirestore(String uid, String fallbackEmail) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists || userDoc.data() == null) {
        return UserModel(
          id: uid,
          email: fallbackEmail,
          name: 'Usuario',
          role: UserRole.cliente,
        );
      }

      final data = userDoc.data()!;
      
      return UserModel(
        id: uid,
        email: data['email'] ?? fallbackEmail,
        name: data['name'] ?? 'Sin nombre',
        role: UserRole.fromString(data['role'] ?? 'cliente'),
      );
    } catch (e) {
      throw Exception('Error al obtener los datos del usuario desde Firestore: $e');
    }
  }

  /// Mapeo opcional de códigos de error de Firebase a mensajes legibles
  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Inténtalo más tarde.';
      default:
        return 'Error de autenticación ($code).';
    }
  }
}
