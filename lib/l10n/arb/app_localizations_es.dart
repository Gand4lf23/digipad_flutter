// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Digipad';

  @override
  String get menuVirtualMirror => 'Espejo Virtual';

  @override
  String get menuSimulations => 'Simulaciones';

  @override
  String get menuLenses3D => 'Lentes 3D';

  @override
  String get menuCosmeticLenses => 'Lentes Cosméticos';

  @override
  String get menuMeasurements => 'Mediciones';

  @override
  String get menuVisualHealth => 'Salud Visual';

  @override
  String get ok => 'Aceptar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String dialogNavigatingContent(String module) {
    return 'Navegando al módulo de $module.';
  }

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get vmNoImages => 'Aún no hay imágenes.\nCaptura una o selecciona desde tu galería para comenzar';

  @override
  String get vmDragAndDrop => 'Arrastra y suelta fotos';

  @override
  String get vmPickOrTake => 'Selecciona una foto de tu galería o toma una nueva';

  @override
  String get vmDropHere => 'Suelta la imagen aquí';

  @override
  String get galleryDeleteTitle => '¿Eliminar imagen?';

  @override
  String get galleryDeleteContent => 'Esto eliminará permanentemente la imagen del almacenamiento.';

  @override
  String get vhNoTests => 'Aún no hay pruebas.';

  @override
  String get vhSelectTest => 'Selecciona una prueba de salud visual';

  @override
  String vhTestSummary(int index, int total) {
    return 'Prueba $index de $total';
  }

  @override
  String get vhSelectAbove => 'Selecciona una prueba de la galería de arriba';

  @override
  String get lensThicknessSimulator => 'Simulador de Espesor de Lentes';

  @override
  String get lensConfiguration => 'Configuración de Lente';

  @override
  String get materialIndex => 'Índice del Material';

  @override
  String get higherIndexHint => 'Índice mayor = lente más delgada';

  @override
  String get prescription => 'Graduación';

  @override
  String rangeDiopters(int min, int max) {
    return 'Rango: $min-$max dioptrías';
  }

  @override
  String get frameType => 'Tipo de Armazón';

  @override
  String get imageNotAvailable => 'Imagen no disponible';

  @override
  String get tryDifferentSettings => 'Prueba diferentes ajustes';

  @override
  String get fullView => 'Vista completa';

  @override
  String get detailView => 'Vista de detalle';

  @override
  String get lensSimulatorTitle => 'Simulador de Lentes';

  @override
  String get refractiveConditions => 'Condiciones refractivas';

  @override
  String get lensTreatments => 'Tratamientos de lentes';

  @override
  String get withoutLens => 'Sin lente';

  @override
  String scenesCount(int count) {
    return '$count escenas';
  }

  @override
  String lensesAvailable(int count) {
    return '$count lentes disponibles';
  }

  @override
  String get selectLensLabel => 'Selecciona una lente:';

  @override
  String get dividerLabel => 'Divisor';

  @override
  String get verticalLabel => 'Vertical';

  @override
  String get horizontalLabel => 'Horizontal';

  @override
  String get dragDivider => 'Arrastra el divisor';

  @override
  String get loadingSimulation => 'Cargando simulación...';

  @override
  String get goBack => 'Volver';

  @override
  String get cameraRequiredTitle => 'Cámara requerida';

  @override
  String get cameraRequiredContent => 'El acceso a la cámara ha sido denegado permanentemente. Habilítalo en la configuración del sistema para usar esta función.';

  @override
  String get openSettings => 'Abrir configuración';

  @override
  String get platformNotSupported => 'Plataforma no soportada';

  @override
  String get placeReferenceHere => 'Coloque la referencia aquí';

  @override
  String get cameraPermissionRequired => 'Permiso de cámara requerido';

  @override
  String get cameraPermissionExplain => 'Necesitamos acceso a la cámara para detectar rostros y referencias.';

  @override
  String get grantPermission => 'Conceder permiso';

  @override
  String detectionIncomplete(int found) {
    return 'Detección incompleta. Se encontraron $found/4 círculos. Intenta con una imagen más clara.';
  }

  @override
  String captureFailed(int found) {
    return 'Captura fallida: Se encontraron $found círculos (se requieren 4). Ajusta la iluminación o distancia.';
  }

  @override
  String get measureAdjustments => 'Ajuste de Medidas';

  @override
  String get guides => 'Guías';

  @override
  String referenceShort(int ref) {
    return 'Ref: $ref';
  }

  @override
  String get unitMm => 'mm';

  @override
  String get ipdDi => 'DIP (DI)';

  @override
  String get bridge => 'Puente';

  @override
  String get frameW => 'Ancho Aro';

  @override
  String get frameH => 'Alto Aro';

  @override
  String get rightEyeP1 => 'Ojo Der (P1)';

  @override
  String get leftEyeP2 => 'Ojo Izq (P2)';

  @override
  String dnpShort(String value) {
    return 'DNP: $value';
  }

  @override
  String heightShort(String value) {
    return 'Alt: $value';
  }

  @override
  String diamShort(String value) {
    return 'Diam: $value';
  }

  @override
  String get leftEye => 'Ojo Izquierdo';

  @override
  String get bothEyes => 'Ambos Ojos';

  @override
  String get rightEye => 'Ojo Derecho';

  @override
  String get size => 'Tamaño';

  @override
  String get opacity => 'Opacidad';

  @override
  String get eyelid => 'Párpado';

  @override
  String get takeOrSelectStart => 'Toma una foto o selecciona desde la galería para comenzar';

  @override
  String get selectBrand => 'Selecciona Marca';

  @override
  String get selectColor => 'Selecciona Color';

  @override
  String get onLabel => 'Encendido';

  @override
  String get offLabel => 'Apagado';

  @override
  String get detectionLabel => 'Detección';

  @override
  String get overlayLabel => 'Superposición';
}
