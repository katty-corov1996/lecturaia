class Libro {
  const Libro({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.genero,
    required this.descripcion,
    required this.anio,
  });

  final int id;
  final String titulo;
  final String autor;
  final String genero;
  final String descripcion;
  final int anio;

  factory Libro.fromJson(Map<String, dynamic> json) {
    return Libro(
      id: json['id'] as int,
      titulo: json['titulo'] as String,
      autor: json['autor'] as String,
      genero: json['genero'] as String,
      descripcion: json['descripcion'] as String,
      anio: json['anio'] as int,
    );
  }
}
