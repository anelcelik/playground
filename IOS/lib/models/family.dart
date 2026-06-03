class Family {
  final List<String> parents;
  final List<String> kids;

  const Family({required this.parents, required this.kids});

  bool get isEmpty => parents.isEmpty;
}
