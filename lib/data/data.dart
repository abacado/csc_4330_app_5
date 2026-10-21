/// Import this file from screens to talk to the server:
///
/// ```dart
/// import '../../data/data.dart';
///
/// final listings = await apiClient.getListings(hobbyId: 'painting');
/// await apiClient.createRequest(
///   listingId: listing.id,
///   requesterId: ApiConfig.demoUserId,
///   message: 'Interested!',
/// );
/// ```
///
/// Every call throws [ApiException] on failure; show `e.message` to the user.
library;

import 'api_client.dart';
import 'api_config.dart';

export 'api_client.dart';
export 'api_config.dart';
export 'models.dart';

/// The shared client the whole app uses.
final ApiClient apiClient = ApiClient(baseUrl: ApiConfig.baseUrl);
