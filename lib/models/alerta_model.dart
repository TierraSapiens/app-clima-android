class AlertaZona {
  final int gid;
  final int maxLevel; // 0: Sin alerta, 1: Amarillo, 2: Naranja, 3: Rojo
  final List<dynamic> coordenadas;

  AlertaZona({
    required this.gid,
    required this.maxLevel,
    required this.coordenadas,
  });
}