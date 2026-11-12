import '../data/datasources/finance_remote_datasource.dart';
import '../data/repositories_impl/finance_repository_impl.dart';
import '../domain/usecases/distribute_order_revenue_usecase.dart';
import '../presentation/providers/finance_provider.dart';

FinanceProvider createFinanceProvider() {
  // 1. Fuente de datos remota (Firestore)
  final remoteDataSource = FinanceRemoteDataSourceImpl();

  // 2. Repositorio que cumple con el contrato (Puerto)
  final repository = FinanceRepositoryImpl(remoteDataSource: remoteDataSource);

  // 3. Caso de uso para distribuir ingresos
  final distributeOrderRevenueUseCase = DistributeOrderRevenueUseCase(repository);

  // 4. Inyección completa al Provider
  return FinanceProvider(financeRepository: repository,
    distributeOrderRevenueUseCase: distributeOrderRevenueUseCase,
  );
}