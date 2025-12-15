import 'package:bloc/bloc.dart';
import 'package:digipad_flutter/screens/features/visual_health/cubit/visual_health_state.dart';

class VisualHealthCubit extends Cubit<VisualHealthState> {
  VisualHealthCubit() : super(VisualHealthState());

  void initTests() {
    final testImages = [
      'assets/images/visual_health/01-Test de Lectura.png',
      'assets/images/visual_health/02-Agudeza visual.png',
      'assets/images/visual_health/03-Bicromatico.png',
      'assets/images/visual_health/04-Ishiara1 .png',
      'assets/images/visual_health/05-Ishiara2.png',
      'assets/images/visual_health/06-Ishiara3.png',
      'assets/images/visual_health/07-Ishiara4.png',
      'assets/images/visual_health/08-Ishiara5.png',
      'assets/images/visual_health/09-Ishiara6.png',
      'assets/images/visual_health/10-Ishiara7.png',
      'assets/images/visual_health/11-Ishiara8.png',
      'assets/images/visual_health/12-Ishiara9.png',
      'assets/images/visual_health/13-Ishiara10.png',
      'assets/images/visual_health/14-Ishiara11.png',
      'assets/images/visual_health/15-Ishiara12.png',
      'assets/images/visual_health/16-Ishiara13.png',
      'assets/images/visual_health/17-Ishiara14.png',
      'assets/images/visual_health/18-Ishiara15.png',
      'assets/images/visual_health/19-Ishiara16.png',
      'assets/images/visual_health/20-Ishiara17.png',
      'assets/images/visual_health/21-Ishiara18.png',
      'assets/images/visual_health/22-Ishiara19.png',
      'assets/images/visual_health/23-Ishiara20.png',
      'assets/images/visual_health/24-Ishiara21.png',
      'assets/images/visual_health/25-Ishiara22.png',
      'assets/images/visual_health/26-Ishiara23.png',
      'assets/images/visual_health/27-Ishiara24.png',
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
