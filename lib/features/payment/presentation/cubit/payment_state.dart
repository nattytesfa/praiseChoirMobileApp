import 'package:equatable/equatable.dart';
import 'package:praise_choir_app/features/payment/data/models/payment_model.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentLoaded extends PaymentState {
  final List<PaymentModel> payments;
  final Map<String, dynamic>? summary;

  const PaymentLoaded(this.payments, {this.summary});

  @override
  List<Object> get props => [payments, summary ?? {}];
}

class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object> get props => [message];
}

class PaymentMarkedAsPaid extends PaymentState {
  final PaymentModel payment;

  const PaymentMarkedAsPaid(this.payment);

  @override
  List<Object> get props => [payment];
}
