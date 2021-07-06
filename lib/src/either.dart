Either<L, R> Left<L, R>(L left) => Either.left(left);
Either<L, R> Right<L, R>(R right) => Either.right(right);

class Either<L, R> {
  final L _left;
  final R _right;

  bool get isLeft => _left != null;
  bool get isRight => !isLeft;

  Either.left(L left)
      : _left = left,
        _right = null;

  Either.right(R right)
      : _right = right,
        _left = null;

  TR fold<TR>(TR Function(L l) leftF, TR Function(R r) rightF) =>
      isLeft ? leftF(_left) : rightF(_right);

  Either<L, RR> map<RR>(RR Function(R r) f) =>
      fold((l) => Left(l), (right) => Right(f(right)));

  Either<LL, RR> biMap<LL, RR>(LL Function(L l) lf, RR Function(R r) rf) =>
      fold((l) => Left(lf(l)), (right) => Right(rf(right)));

  Either<L, void> foreEach(void Function(R r) f) => map(f);

  Either<L, RR> bind<RR>(Either<L, RR> Function(R r) f) =>
      fold((l) => Left(l), (right) => f(right));
}
