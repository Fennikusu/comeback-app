import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../../config/constants.dart';

class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool success;

  ApiResponse({
    this.data,
    this.error,
    required this.success,
  });
}

class ApiClient {
  final String baseUrl;
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? AppConstants.baseApiUrl;

  void setAuthToken(String token) {
    _headers['Authorization'] = 'Bearer $token';
  }

  void removeAuthToken() {
    _headers.remove('Authorization');
  }

  Future<ApiResponse<T>> get<T>(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
        T Function(dynamic)? parser,
      }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParameters?.map(
              (key, value) => MapEntry(key, value.toString()),
        ),
      );

      developer.log('GET Request to: $uri');
      developer.log('Headers: $_headers');

      final response = await http.get(uri, headers: _headers);

      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');

      if (response.statusCode >= 400) {
        String errorMessage = 'Une erreur est survenue';
        try {
          final bodyData = json.decode(response.body);
          if (bodyData['message'] != null) {
            errorMessage = bodyData['message'];
          }
        } catch (e) {
          if (response.body.isNotEmpty) {
            errorMessage = response.body;
          }
        }
        return ApiResponse(success: false, error: errorMessage);
      }

      try {
        final dynamic decodedBody = json.decode(response.body);
        if (parser != null) {
          final T parsedData = parser(decodedBody);
          return ApiResponse(data: parsedData, success: true);
        }
        return ApiResponse(data: decodedBody as T, success: true);
      } catch (e) {
        developer.log('Error parsing response', error: e);
        return ApiResponse(
          success: false,
          error: 'Erreur lors du traitement de la réponse',
        );
      }
    } catch (e) {
      developer.log('Network error', error: e);
      return ApiResponse(success: false, error: 'Erreur de connexion');
    }
  }

  Future<ApiResponse<T>> post<T>(
      String endpoint, {
        Map<String, dynamic>? body,
        T Function(Map<String, dynamic>)? parser,
      }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      developer.log('POST Request to: $uri');
      developer.log('Headers: $_headers');
      developer.log('Body: ${json.encode(body)}');

      final response = await http.post(
        uri,
        headers: _headers,
        body: json.encode(body),
      );

      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');

      if (response.statusCode >= 400) {
        String errorMessage = 'Une erreur est survenue';
        try {
          final bodyData = json.decode(response.body);
          if (bodyData['message'] != null) {
            errorMessage = bodyData['message'];
          }
        } catch (e) {
          if (response.body.contains('Invalid credentials')) {
            errorMessage = 'Identifiants invalides';
          }
        }
        return ApiResponse(success: false, error: errorMessage);
      }

      try {
        final Map<String, dynamic> bodyData = json.decode(response.body);
        if (parser != null) {
          final T parsedData = parser(bodyData);
          return ApiResponse(data: parsedData, success: true);
        }
        return ApiResponse(data: bodyData as T, success: true);
      } catch (e) {
        developer.log('Error parsing response', error: e);
        return ApiResponse(
          success: false,
          error: 'Erreur lors du traitement de la réponse',
        );
      }
    } catch (e) {
      developer.log('Network error', error: e);
      return ApiResponse(success: false, error: 'Erreur de connexion');
    }
  }

  Future<ApiResponse<T>> put<T>(
      String endpoint, {
        Map<String, dynamic>? body,
        T Function(Map<String, dynamic>)? parser,
      }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.put(
        uri,
        headers: _headers,
        body: body != null ? json.encode(body) : null,
      );

      return _handleResponse(response, parser);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<T>> delete<T>(
      String endpoint, {
        T Function(Map<String, dynamic>)? parser,
      }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.delete(uri, headers: _headers);
      return _handleResponse(response, parser);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  ApiResponse<T> _handleResponse<T>(
      http.Response response,
      T Function(Map<String, dynamic>)? parser,
      ) {
    try {
      final Map<String, dynamic> bodyData = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (parser != null) {
          final T parsedData = parser(bodyData);
          return ApiResponse(data: parsedData, success: true);
        }
        return ApiResponse(data: bodyData as T, success: true);
      }

      String error = bodyData['message'] ?? 'Une erreur est survenue';
      return ApiResponse(success: false, error: error);
    } catch (e) {
      developer.log('Error parsing response', error: e);
      return ApiResponse(
        success: false,
        error: 'Erreur lors du traitement de la réponse',
      );
    }
  }
}
