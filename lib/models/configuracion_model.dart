class ConfiguracionModel {
  final String unidadTemperatura;
  final String unidadViento;
  final String unidadPrecipitacion;
  final String unidadPresion;
  final bool alertasLocalesActivas;

  ConfiguracionModel({
    this.unidadTemperatura = 'C',
    this.unidadViento = 'km/h',
    this.unidadPrecipitacion = 'mm',
    this.unidadPresion = 'hPa',
    this.alertasLocalesActivas = true,
  });

  ConfiguracionModel copyWith({
    String? unidadTemperatura,
    String? unidadViento,
    String? unidadPrecipitacion,
    String? unidadPresion,
    bool? alertasLocalesActivas,
  }) {
    return ConfiguracionModel(
      unidadTemperatura: unidadTemperatura ?? this.unidadTemperatura,
      unidadViento: unidadViento ?? this.unidadViento,
      unidadPrecipitacion: unidadPrecipitacion ?? this.unidadPrecipitacion,
      unidadPresion: unidadPresion ?? this.unidadPresion,
      alertasLocalesActivas: alertasLocalesActivas ?? this.alertasLocalesActivas,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'unidadTemperatura': unidadTemperatura,
      'unidadViento': unidadViento,
      'unidadPrecipitacion': unidadPrecipitacion,
      'unidadPresion': unidadPresion,
      'alertasLocalesActivas': alertasLocalesActivas,
    };
  }

  factory ConfiguracionModel.fromMap(Map<String, dynamic> map) {
    return ConfiguracionModel(
      unidadTemperatura: map['unidadTemperatura'] ?? 'C',
      unidadViento: map['unidadViento'] ?? 'km/h',
      unidadPrecipitacion: map['unidadPrecipitacion'] ?? 'mm',
      unidadPresion: map['unidadPresion'] ?? 'hPa',
      alertasLocalesActivas: map['alertasLocalesActivas'] ?? true,
    );
  }
}