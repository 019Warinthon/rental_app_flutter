import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/utils/logger.dart';
import '../../home/models/review_model.dart';

class ReviewProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  final Map<String, List<ReviewModel>> _reviewsByProperty = {};
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<ReviewModel> getReviews(String propertyId) {
    return _reviewsByProperty[propertyId] ?? [];
  }

  Future<void> fetchReviews(String propertyId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.get('/properties/$propertyId/reviews');

      List<dynamic> data = [];
      if (response is Map && response.containsKey('data')) {
        data = response['data'] as List<dynamic>;
      } else if (response is List) {
        data = response;
      }

      _reviewsByProperty[propertyId] = data
          .map((json) => ReviewModel.fromJson(json))
          .toList();
    } catch (e) {
      Logger.error('Failed to fetch reviews for property $propertyId', e);
      _reviewsByProperty[propertyId] = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addReview(
    String propertyId,
    String userName,
    double rating,
    String comment,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        '/properties/$propertyId/reviews',
        data: {'userName': userName, 'rating': rating, 'comment': comment},
      );

      if (response != null && response['id'] != null) {
        final newReview = ReviewModel.fromJson(response);
        if (_reviewsByProperty.containsKey(propertyId)) {
          _reviewsByProperty[propertyId]!.insert(0, newReview);
        } else {
          _reviewsByProperty[propertyId] = [newReview];
        }
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('Failed to add review for property $propertyId', e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
