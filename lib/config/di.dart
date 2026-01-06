import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:praise_choir_app/features/auth/data/auth_repository.dart';
import 'package:praise_choir_app/features/auth/data/repositories/user_repository.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';

// dependency injection setup
final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository());
  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepository>()));
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepository(firestore: FirebaseFirestore.instance),
  );
}
