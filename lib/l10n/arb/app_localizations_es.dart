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

  @override
  String get simCatMyopia => 'Miopía';

  @override
  String get simCatMyopiaDesc => 'Dificultad para ver claramente objetos lejanos (miopía)';

  @override
  String get simSceneKitchen => 'Cocina';

  @override
  String get simSceneMarket => 'Mercado';

  @override
  String get simSceneGrocery => 'Supermercado';

  @override
  String get simSceneClothingStore => 'Tienda de Ropa';

  @override
  String get simLensMonofocalNear => 'Monofocal Cerca';

  @override
  String get simLensMonofocalFar => 'Monofocal Lejos';

  @override
  String get simCatMultifocal => 'Multifocal';

  @override
  String get simCatMultifocalDesc => 'Comparación de calidad de lentes progresivos';

  @override
  String get simSceneClothing => 'Ropa';

  @override
  String get simQualityEconomy => 'Económico';

  @override
  String get simQualityStandard => 'Estándar';

  @override
  String get simQualityGood => 'Bueno';

  @override
  String get simQualityPremium => 'Premium';

  @override
  String get simCatBifocal => 'Bifocal';

  @override
  String get simCatBifocalDesc => 'Comparación entre lentes bifocales y multifocales';

  @override
  String get simSceneOffice => 'Oficina';

  @override
  String get simSceneDriving => 'Conducción';

  @override
  String get simLensInvisibleBifocal => 'Bifocal Invisible';

  @override
  String get simLensMultifocal => 'Multifocal';

  @override
  String get simCatPolarized => 'Polarizado';

  @override
  String get simCatPolarizedDesc => 'Reducción de reflejos y deslumbramiento';

  @override
  String get simSceneGolf => 'Golf';

  @override
  String get simSceneBeach => 'Playa';

  @override
  String get simSceneTennis => 'Tenis';

  @override
  String get simSceneYacht => 'Yate';

  @override
  String get simSceneMotorcycle => 'Motocicleta';

  @override
  String get simCatAntiReflective => 'Antirreflejo';

  @override
  String get simCatAntiReflectiveDesc => 'Reducción de reflejos en la lente y mejor claridad';

  @override
  String get simSceneBaseball => 'Béisbol';

  @override
  String get simSceneBasketball => 'Baloncesto';

  @override
  String get simSceneSoccer => 'Fútbol';

  @override
  String get simSceneConcert => 'Concierto';

  @override
  String get simSceneBridge => 'Puente';

  @override
  String get simCatDriveWear => 'DriveWear';

  @override
  String get simCatDriveWearDesc => 'Lentes optimizados para conducir en diferentes condiciones';

  @override
  String get simSceneDrivingSunny => 'Conducción (Soleado)';

  @override
  String get simSceneDrivingCloudy => 'Conducción (Nublado)';

  @override
  String get simSceneGolfSunny => 'Golf (Soleado)';

  @override
  String get simSceneGolfCloudy => 'Golf (Nublado)';

  @override
  String get simSceneBeachSunny => 'Playa (Soleado)';

  @override
  String get simSceneBeachCloudy => 'Playa (Nublado)';

  @override
  String get simSceneMotorcycleSunny => 'Motocicleta (Soleado)';

  @override
  String get simSceneMotorcycleCloudy => 'Motocicleta (Nublado)';

  @override
  String get simSceneTennisSunny => 'Tenis (Soleado)';

  @override
  String get simSceneTennisCloudy => 'Tenis (Nublado)';

  @override
  String get simSceneYachtSunny => 'Yate (Soleado)';

  @override
  String get simSceneYachtCloudy => 'Yate (Nublado)';

  @override
  String get simCatPhotochromic => 'Fotocromático';

  @override
  String get simCatPhotochromicDesc => 'Lentes que se adaptan a las condiciones de luz';

  @override
  String get simSceneOpticStore => 'Óptica';

  @override
  String get simColorGray => 'Gris';

  @override
  String get simColorBrown => 'Marrón';

  @override
  String get simColorGreen => 'Verde';

  @override
  String get simColorSunBalance => 'SunBalance';

  @override
  String get simCatSolar => 'Solar';

  @override
  String get simCatSolarDesc => 'Protección solar con recubrimiento antirreflejo';

  @override
  String get simSceneBeach2 => 'Playa 2';

  @override
  String get simSceneCar => 'Auto';

  @override
  String get simLensWithAR => 'Con AR';

  @override
  String get simCatTint => 'Tinte';

  @override
  String get simCatTintDesc => 'Tintes de lentes personalizables para diferentes entornos';

  @override
  String get simColorYellow => 'Amarillo';

  @override
  String get simColorAqua => 'Aguamarina';

  @override
  String get simColorBlue => 'Azul';

  @override
  String get simColorOrange => 'Naranja';

  @override
  String get simColorRed => 'Rojo';
}
