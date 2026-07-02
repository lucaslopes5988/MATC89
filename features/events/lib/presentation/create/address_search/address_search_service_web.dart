import 'dart:js_interop';

import 'package:google_maps/google_maps_places.dart' as places;

import 'address_search_result.dart';

class AddressSearchService {
  Future<List<AddressSearchResult>> search(String query) async {
    final response = await _fetchAutocompleteSuggestions(
      places.AutocompleteRequest(
        input: query,
        includedRegionCodes: ['br'].jsify() as JSArray<JSString>,
        language: 'pt-BR',
        region: 'br',
      ),
    );

    final results = <AddressSearchResult>[];
    for (final suggestion in response.suggestions.take(5)) {
      final prediction = suggestion.placePrediction;
      if (prediction == null) continue;

      final result = await _resolvePrediction(prediction);
      if (result != null) {
        results.add(result);
      }
    }

    return results;
  }

  Future<_AutocompleteSuggestionsResponse> _fetchAutocompleteSuggestions(
    places.AutocompleteRequest request,
  ) async {
    final promise = places.AutocompleteSuggestion.fetchAutocompleteSuggestions(
      request,
    );
    final response = await (promise! as JSPromise<JSObject>).toDart;
    return _AutocompleteSuggestionsResponse(response);
  }

  Future<AddressSearchResult?> _resolvePrediction(
    places.PlacePrediction prediction,
  ) async {
    final place = prediction.toPlace();
    await (place.fetchFields(
      places.FetchFieldsRequest(
        fields: ['displayName', 'formattedAddress', 'location'].jsify()
            as JSArray<JSString>,
      ),
            )!
            as JSPromise<JSObject>)
        .toDart;

    final location = place.location;
    if (location == null) return null;

    final fallback = prediction.text.text;
    final title = (place.displayName ?? prediction.mainText?.text ?? '').trim();
    final subtitle =
        (place.formattedAddress ?? prediction.secondaryText?.text ?? '').trim();

    return AddressSearchResult(
      title: title.isEmpty ? fallback : title,
      subtitle: subtitle.isEmpty ? fallback : subtitle,
      latitude: location.lat.toDouble(),
      longitude: location.lng.toDouble(),
    );
  }
}

extension type _AutocompleteSuggestionsResponse(JSObject _)
    implements JSObject {
  @JS('suggestions')
  external JSArray<places.AutocompleteSuggestion> _suggestions;

  List<places.AutocompleteSuggestion> get suggestions => _suggestions.toDart;
}
