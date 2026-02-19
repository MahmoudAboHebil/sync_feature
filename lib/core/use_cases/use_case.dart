abstract class UseCase<Ttype, Params> {
  Future<Ttype> call(Params params);
}
