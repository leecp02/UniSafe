import 'package:cloud_firestore/cloud_firestore.dart';

class SelfCheckService {
  SelfCheckService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchAssessments(String uid, {int limit = 8}) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('mdq_assessments')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<void> addMdqAssessment({
    required String uid,
    required String category,
    required List<bool> answers,
    required bool timingClustered,
    required String impact,
    required int rawScore,
    required double endorsementPercent,
    required bool positiveScreen,
    required int positiveActivation,
    required int negativeActivation,
    required String riskStatus,
  }) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('mdq_assessments')
        .add({
      'assessmentType': 'mdq',
      'category': category,
      'createdAt': FieldValue.serverTimestamp(),
      'answers': answers,
      'timingClustered': timingClustered,
      'impact': impact,
      'rawScore': rawScore,
      'endorsementPercent': endorsementPercent,
      'positiveScreen': positiveScreen,
      'positiveActivation': {
        'items': <int>[3, 4, 8, 9],
        'score': positiveActivation,
      },
      'negativeActivation': {
        'items': <int>[1, 2, 6, 7, 12, 13],
        'score': negativeActivation,
      },
      'riskStatus': riskStatus,
    });
  }

  Future<void> addStressAssessment({
    required String uid,
    required List<bool> answers,
    required int score,
    required String riskStatus,
    required String resultMessage,
    required List<String> suggestions,
  }) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('mdq_assessments')
        .add({
      'assessmentType': 'stress',
      'category': 'Stress Check',
      'createdAt': FieldValue.serverTimestamp(),
      'answers': answers,
      'score': score,
      'riskStatus': riskStatus,
      'resultMessage': resultMessage,
      'suggestions': suggestions,
    });
  }

  Future<void> addWellbeingAssessment({
    required String uid,
    required List<int?> emotionsAnswers,
    required List<int?> behaviorAnswers,
    required List<int?> supportAnswers,
    required List<int?> strengthAnswers,
    required List<int?> lifeAnswers,
    required int finalAnswer,
    required int emotionScore,
    required int behaviorScore,
    required int supportScore,
    required int strengthScore,
    required int lifeScore,
    required int concernScore,
    required int protectiveScore,
    required int finalAdjustment,
    required int overallScore,
    required String riskStatus,
    required String resultMessage,
    required List<String> focusAreas,
    required List<String> suggestions,
  }) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('mdq_assessments')
        .add({
      'assessmentType': 'wellbeing',
      'category': 'Wellbeing Check',
      'createdAt': FieldValue.serverTimestamp(),
      'emotionsAnswers': emotionsAnswers,
      'behaviorAnswers': behaviorAnswers,
      'supportAnswers': supportAnswers,
      'strengthAnswers': strengthAnswers,
      'lifeAnswers': lifeAnswers,
      'finalAnswer': finalAnswer,
      'emotionScore': emotionScore,
      'behaviorScore': behaviorScore,
      'supportScore': supportScore,
      'strengthScore': strengthScore,
      'lifeScore': lifeScore,
      'concernScore': concernScore,
      'protectiveScore': protectiveScore,
      'finalAdjustment': finalAdjustment,
      'overallScore': overallScore,
      'riskStatus': riskStatus,
      'resultMessage': resultMessage,
      'focusAreas': focusAreas,
      'suggestions': suggestions,
    });
  }

  Future<void> deleteAssessment({
    required String uid,
    required String assessmentId,
  }) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('mdq_assessments')
        .doc(assessmentId)
        .delete();
  }
}
