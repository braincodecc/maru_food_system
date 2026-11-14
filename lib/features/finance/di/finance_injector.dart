import '../data/datasources/finance_remote_datasource.dart';
import '../data/repositories_impl/finance_repository_impl.dart';
import '../presentation/providers/finance_provider.dart';

FinanceProvider createFinanceProvider() {
  // 1. Fuente de datos remota (Firestore)
  final remoteDataSource = FinanceRemoteDataSourceImpl();

  // 2. Repositorio que cumple con el contrato (Puerto)
  final financeRepository = FinanceRepositoryImpl(remoteDataSource: remoteDataSource);

  // 3. Inyección completa al Provider
  return FinanceProvider(financeRepository: financeRepository);
}
