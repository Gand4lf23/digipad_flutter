import 'package:bloc/bloc.dart';
import 'package:digipad_flutter/screens/features/visual_health/cubit/visual_health_state.dart';

class VisualHealthCubit extends Cubit<VisualHealthState> {
  VisualHealthCubit() : super(VisualHealthState());

  void initTests() {
    final testImages = [
      'assets/images/visual_health/01-Test de Lectura.webp',
      'assets/images/visual_health/02-Agudeza visual.webp',
      'assets/images/visual_health/03-Bicromatico.webp',
      'assets/images/visual_health/04-Ishiara1 .webp',
      'assets/images/visual_health/05-Ishiara2.webp',
      'assets/images/visual_health/06-Ishiara3.webp',
      'assets/images/visual_health/07-Ishiara4.webp',
      'assets/images/visual_health/08-Ishiara5.webp',
      'assets/images/visual_health/09-Ishiara6.webp',
      'assets/images/visual_health/10-Ishiara7.webp',
      'assets/images/visual_health/11-Ishiara8.webp',
      'assets/images/visual_health/12-Ishiara9.webp',
      'assets/images/visual_health/13-Ishiara10.webp',
      'assets/images/visual_health/14-Ishiara11.webp',
      'assets/images/visual_health/15-Ishiara12.webp',
      'assets/images/visual_health/16-Ishiara13.webp',
      'assets/images/visual_health/17-Ishiara14.webp',
      'assets/images/visual_health/18-Ishiara15.webp',
      'assets/images/visual_health/19-Ishiara16.webp',
      'assets/images/visual_health/20-Ishiara17.webp',
      'assets/images/visual_health/21-Ishiara18.webp',
      'assets/images/visual_health/22-Ishiara19.webp',
      'assets/images/visual_health/23-Ishiara20.webp',
      'assets/images/visual_health/24-Ishiara21.webp',
      'assets/images/visual_health/25-Ishiara22.webp',
      'assets/images/visual_health/26-Ishiara23.webp',
      'assets/images/visual_health/27-Ishiara24.webp',
    ];

    emit(
      state.copyWith(
        testImages: testImages,
        isInitialized: true,
        currentTestIndex: 0,
      ),
    );
  }

  void selectTest(int index) {
    if (index >= 0 && index < state.testImages.length) {
      emit(state.copyWith(currentTestIndex: index));
    }
  }

  void nextTest() {
    if (state.currentTestIndex < state.testImages.length - 1) {
      emit(state.copyWith(currentTestIndex: state.currentTestIndex + 1));
    }
  }

  void previousTest() {
    if (state.currentTestIndex > 0) {
      emit(state.copyWith(currentTestIndex: state.currentTestIndex - 1));
    }
  }

  void reset() {
    emit(state.copyWith(currentTestIndex: 0));
  }
}
