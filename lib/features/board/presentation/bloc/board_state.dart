import 'package:equatable/equatable.dart';
import '../../domain/entities/board_entity.dart';

abstract class BoardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BoardInitial extends BoardState {}
class BoardLoading extends BoardState {}
class BoardError extends BoardState {
  final String message;
  BoardError(this.message);
  @override
  List<Object?> get props => [message];
}

class BoardLoaded extends BoardState {
  final List<ColumnEntity> columns;
  final String projectId;
  BoardLoaded({required this.columns, required this.projectId});
  @override
  List<Object?> get props => [columns, projectId];
}