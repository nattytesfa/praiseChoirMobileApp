import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/features/payment/data/payment_repository.dart';
import 'package:praise_choir_app/features/payment/data/models/payment_settings.dart';
import 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRepository paymentRepository;

  PaymentCubit({PaymentRepository? repository})
    : paymentRepository = repository ?? PaymentRepository(),
      super(PaymentInitial());

  void loadMyPayments(String memberId) async {
    emit(PaymentLoading());
    try {
      final payments = await paymentRepository.getPaymentsForMember(memberId);
      emit(PaymentLoaded(payments));
    } catch (e) {
      emit(PaymentError('Failed to load payments'));
    }
  }

  void loadAllPayments() async {
    emit(PaymentLoading());
    try {
      final payments = await paymentRepository.getAllPayments();
      final currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
      final summary = await paymentRepository.getPaymentSummary(currentMonth);
      emit(PaymentLoaded(payments, summary: summary));
    } catch (e) {
      emit(PaymentError('Failed to load all payments'));
    }
  }

  void loadPaymentSummary(DateTime month) async {
    emit(PaymentLoading());
    try {
      final payments = await paymentRepository.getPaymentsForMonth(month);
      final summary = await paymentRepository.getPaymentSummary(month);
      emit(PaymentLoaded(payments, summary: summary));
    } catch (e) {
      emit(PaymentError('Failed to load payment summary'));
    }
  }

  Future<void> markPaymentAsPaid(
    String paymentId, {
    String proofImagePath = 'proof_path',
    double additionalFee = 0,
    String? memberId,
  }) async {
    try {
      await paymentRepository.markPaymentAsPaid(
        paymentId,
        proofImagePath,
        additionalFee: additionalFee,
      );

      if (memberId != null) {
        loadMyPayments(memberId);
      } else {
        loadAllPayments();
      }
    } catch (e) {
      emit(PaymentError('Failed to mark payment as paid'));
    }
  }

  Future<void> updatePaymentProof(
    String paymentId,
    String proofImagePath, {
    String? memberId,
  }) async {
    try {
      await paymentRepository.updatePaymentProof(paymentId, proofImagePath);
      if (memberId != null) {
        loadMyPayments(memberId);
      } else {
        loadAllPayments();
      }
    } catch (e) {
      emit(PaymentError('Failed to update payment proof'));
    }
  }

  Future<void> removePaymentProof(String paymentId, {String? memberId}) async {
    try {
      await paymentRepository.removePaymentProof(paymentId);
      if (memberId != null) {
        loadMyPayments(memberId);
      } else {
        loadAllPayments();
      }
    } catch (e) {
      emit(PaymentError('Failed to remove payment proof'));
    }
  }

  void getOverduePayments() async {
    emit(PaymentLoading());
    try {
      final overduePayments = await paymentRepository.getOverduePayments();
      emit(PaymentLoaded(overduePayments));
    } catch (e) {
      emit(PaymentError('Failed to load overdue payments'));
    }
  }

  void createMonthlyPayments(List<String> memberIds) async {
    emit(PaymentLoading());
    try {
      final settings = await paymentRepository.getSettings();
      final dueDate = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        settings.dueDay,
      );
      await paymentRepository.createMonthlyPayments(memberIds, dueDate);
      await paymentRepository.saveSettings(settings);
      loadAllPayments();
    } catch (e) {
      emit(PaymentError('Failed to create monthly payments'));
    }
  }

  void deleteMonthlyPayments({bool includePaid = false}) async {
    emit(PaymentLoading());
    try {
      final currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
      await paymentRepository.deletePaymentsForMonth(
        currentMonth,
        includePaid: includePaid,
      );
      loadAllPayments();
    } catch (e) {
      emit(PaymentError('Failed to delete monthly payments'));
    }
  }

  // ==================== SETTINGS ====================

  void loadSettings() async {
    try {
      final settings = await paymentRepository.getSettings();
      emit(PaymentSettingsLoaded(settings));
    } catch (e) {
      emit(PaymentError('Failed to load payment settings'));
    }
  }

  Future<void> updateSettings(PaymentSettings settings) async {
    try {
      await paymentRepository.saveSettings(settings);
      loadAllPayments();
    } catch (e) {
      emit(PaymentError('Failed to save payment settings'));
    }
  }

  Future<void> manualGenerateWithSettings(List<String> activeMemberIds) async {
    emit(PaymentLoading());
    try {
      final settings = await paymentRepository.getSettings();
      final dueDate = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        settings.dueDay,
      );
      await paymentRepository.createMonthlyPayments(
        activeMemberIds,
        dueDate,
        amount: settings.paymentAmount,
      );
      settings.lastGenerated = DateTime.now();
      await paymentRepository.saveSettings(settings);
      loadAllPayments();
    } catch (e) {
      emit(PaymentError('Failed to generate payments'));
    }
  }
}
