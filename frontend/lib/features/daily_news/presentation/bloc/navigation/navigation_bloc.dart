import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Event
abstract class NavigationEvent extends Equatable {
  const NavigationEvent();
  @override
  List<Object> get props => [];
}

class NavigationTabChanged extends NavigationEvent {
  final int tabIndex;
  const NavigationTabChanged(this.tabIndex);
  @override
  List<Object> get props => [tabIndex];
}

// State
class NavigationState extends Equatable {
  final int index;
  const NavigationState(this.index);
  @override
  List<Object> get props => [index];
}

// Bloc
class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState(0)) {
    on<NavigationTabChanged>((event, emit) {
      emit(NavigationState(event.tabIndex));
    });
  }
}
