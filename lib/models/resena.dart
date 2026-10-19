class Resena {
  final int id;
  final int usuarioId;
  final int libroId;
  final String comentario;
  final int calificacion;

  const Resena({
    required this.id,
    required this.usuarioId,
    required this.libroId,
    required this.comentario,
    required this.calificacion,
  });

  factory Resena.fromJson(Map<String, dynamic> json) {
    return Resena(
      id: json['id'] as int,
      usuarioId: json['usuario_id'] as int,
      libroId: json['libro_id'] as int,
      comentario: json['comentario'] as String,
      calificacion: json['calificacion'] as int,
    );
  }
}
