// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Digipad';

  @override
  String get menuVirtualMirror => 'Espelho Virtual';

  @override
  String get menuSimulations => 'Simulações';

  @override
  String get menuLenses3D => 'Lentes 3D';

  @override
  String get menuCosmeticLenses => 'Lentes Cosméticas';

  @override
  String get menuMeasurements => 'Medições';

  @override
  String get menuVisualHealth => 'Saúde Visual';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String dialogNavigatingContent(String module) {
    return 'Navegando para o módulo $module.';
  }

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get vmNoImages => 'Nenhuma imagem carregada ainda.\nCapture uma ou selecione da galeria para começar';

  @override
  String get vmDragAndDrop => 'Arraste e solte fotos';

  @override
  String get vmPickOrTake => 'Escolha uma foto da galeria ou tire uma nova';

  @override
  String get vmDropHere => 'Solte a imagem aqui';

  @override
  String get galleryDeleteTitle => 'Excluir imagem?';

  @override
  String get galleryDeleteContent => 'Isso removerá permanentemente a imagem do armazenamento.';

  @override
  String get vhNoTests => 'Nenhum teste carregado.';

  @override
  String get vhSelectTest => 'Selecione um teste de saúde visual';

  @override
  String vhTestSummary(int index, int total) {
    return 'Teste $index de $total';
  }

  @override
  String get vhSelectAbove => 'Selecione um teste na galeria acima';

  @override
  String get lensThicknessSimulator => 'Simulador de Espessura de Lentes';

  @override
  String get lensConfiguration => 'Configuração da Lente';

  @override
  String get materialIndex => 'Índice do Material';

  @override
  String get higherIndexHint => 'Índice maior = lente mais fina';

  @override
  String get prescription => 'Prescrição';

  @override
  String rangeDiopters(int min, int max) {
    return 'Faixa: $min-$max dioptrias';
  }

  @override
  String get frameType => 'Tipo de Armação';

  @override
  String get imageNotAvailable => 'Imagem indisponível';

  @override
  String get tryDifferentSettings => 'Tente configurações diferentes';

  @override
  String get fullView => 'Visão completa';

  @override
  String get detailView => 'Visão detalhada';

  @override
  String get lensSimulatorTitle => 'Simulador de Lentes';

  @override
  String get refractiveConditions => 'Condições refrativas';

  @override
  String get lensTreatments => 'Tratamentos de lentes';

  @override
  String get withoutLens => 'Sem lente';

  @override
  String scenesCount(int count) {
    return '$count cenas';
  }

  @override
  String lensesAvailable(int count) {
    return '$count lentes disponíveis';
  }

  @override
  String get selectLensLabel => 'Selecione uma lente:';

  @override
  String get dividerLabel => 'Divisor';

  @override
  String get verticalLabel => 'Vertical';

  @override
  String get horizontalLabel => 'Horizontal';

  @override
  String get dragDivider => 'Arraste o divisor';

  @override
  String get loadingSimulation => 'Carregando simulação...';

  @override
  String get goBack => 'Voltar';

  @override
  String get cameraRequiredTitle => 'Câmera necessária';

  @override
  String get cameraRequiredContent => 'O acesso à câmera foi negado permanentemente. Habilite-o nas configurações do sistema para usar este recurso.';

  @override
  String get openSettings => 'Abrir configurações';

  @override
  String get platformNotSupported => 'Plataforma não suportada';

  @override
  String get placeReferenceHere => 'Coloque a referência aqui';

  @override
  String get cameraPermissionRequired => 'Permissão de câmera necessária';

  @override
  String get cameraPermissionExplain => 'Precisamos de acesso à câmera para detectar rostos e marcadores de referência.';

  @override
  String get grantPermission => 'Conceder permissão';

  @override
  String detectionIncomplete(int found) {
    return 'Detecção incompleta. Encontrados $found/4 círculos. Tente uma imagem mais clara.';
  }

  @override
  String captureFailed(int found) {
    return 'Falha na captura: Encontrados $found círculos (4 necessários). Ajuste a iluminação ou distância.';
  }

  @override
  String get measureAdjustments => 'Ajuste de Medidas';

  @override
  String get guides => 'Guias';

  @override
  String referenceShort(int ref) {
    return 'Ref: $ref';
  }

  @override
  String get unitMm => 'mm';

  @override
  String get ipdDi => 'DIP (DI)';

  @override
  String get bridge => 'Ponte';

  @override
  String get frameW => 'Largura da armação';

  @override
  String get frameH => 'Altura da armação';

  @override
  String get rightEyeP1 => 'Olho Dir (P1)';

  @override
  String get leftEyeP2 => 'Olho Esq (P2)';

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
  String get leftEye => 'Olho Esquerdo';

  @override
  String get bothEyes => 'Ambos os Olhos';

  @override
  String get rightEye => 'Olho Direito';

  @override
  String get size => 'Tamanho';

  @override
  String get opacity => 'Opacidade';

  @override
  String get eyelid => 'Pálpebra';

  @override
  String get takeOrSelectStart => 'Tire uma foto ou selecione da Galeria para começar';

  @override
  String get selectBrand => 'Selecione a Marca';

  @override
  String get selectColor => 'Selecione a Cor';

  @override
  String get onLabel => 'Ligado';

  @override
  String get offLabel => 'Desligado';

  @override
  String get detectionLabel => 'Detecção';

  @override
  String get overlayLabel => 'Sobreposição';
}
