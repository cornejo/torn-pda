// Dart imports:
import 'dart:async';
import 'dart:convert';

// Package imports:
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Project imports:
import 'package:torn_pda/models/chaining/attack_full_model.dart';
import 'package:torn_pda/models/chaining/attack_model.dart';
import 'package:torn_pda/models/chaining/bars_model.dart';
import 'package:torn_pda/models/chaining/chain_model.dart';
import 'package:torn_pda/models/chaining/target_model.dart';
import 'package:torn_pda/models/education_model.dart';
import 'package:torn_pda/models/faction/faction_crimes_model.dart';
import 'package:torn_pda/models/faction/faction_model.dart';
import 'package:torn_pda/models/friends/friend_model.dart';
import 'package:torn_pda/models/inventory_model.dart';
import 'package:torn_pda/models/items_model.dart';
import 'package:torn_pda/models/profile/bazaar_model.dart';
import 'package:torn_pda/models/profile/other_profile_model.dart';
import 'package:torn_pda/models/profile/own_profile_basic.dart';
import 'package:torn_pda/models/profile/own_profile_misc.dart';
import 'package:torn_pda/models/profile/own_profile_model.dart';
import 'package:torn_pda/models/property_model.dart';
import 'package:torn_pda/models/stockmarket/stockmarket_model.dart';
import 'package:torn_pda/models/stockmarket/stockmarket_user_model.dart';
import 'package:torn_pda/models/travel/travel_model.dart';

enum ApiType {
  user,
  faction,
  torn,
  property,
}

enum ApiSelection {
  travel,
  ownBasic,
  ownExtended,
  ownMisc,
  bazaar,
  otherProfile,
  target,
  attacks,
  attacksFull,
  chainStatus,
  bars,
  items,
  inventory,
  education,
  faction,
  factionCrimes,
  friends,
  property,
  stocks,
}

class ApiError {
  int errorId;
  String errorReason;
  ApiError({int errorId}) {
    switch (errorId) {
      // Torn PDA codes
      case 100:
        errorReason = 'connection timed out';
        break;
      // Torn codes
      case 0:
        errorReason = 'no connection';
        break;
      case 1:
        errorReason = 'key is empty';
        break;
      case 2:
        errorReason = 'incorrect Key';
        break;
      case 3:
        errorReason = 'wrong type';
        break;
      case 4:
        errorReason = 'wrong fields';
        break;
      case 5:
        errorReason = 'too many requests';
        break;
      case 6:
        errorReason = 'incorrect ID';
        break;
      case 7:
        errorReason = 'incorrect ID-entity relation';
        break;
      case 8:
        errorReason = 'IP block';
        break;
      case 9:
        errorReason = 'API disabled (probably under maintenance by Torn\'s '
            'developers)!';
        break;
      case 10:
        errorReason = 'key owner is in federal jail';
        break;
      case 11:
        errorReason = 'key change error: You can only '
            'change your API key once every 60 seconds';
        break;
      case 12:
        errorReason = 'key read error: Error reading key from Database';
        break;
      case 13:
        errorReason = 'key is temporary disabled due to owner inactivity';
        break;
      case 14:
        errorReason = 'daily read limit reached.';
        break;
    }
  }
}

class TornApiCaller {
  String apiKey;
  String queryId;
  int limit;

  TornApiCaller.travel(this.apiKey);
  TornApiCaller.ownBasic(this.apiKey);
  TornApiCaller.ownExtended(this.apiKey, this.limit);
  TornApiCaller.ownMisc(this.apiKey);
  TornApiCaller.bazaar(this.apiKey);
  TornApiCaller.otherProfile(this.apiKey, this.queryId);
  TornApiCaller.target(this.apiKey, this.queryId);
  TornApiCaller.attacks(this.apiKey);
  TornApiCaller.chain(this.apiKey);
  TornApiCaller.bars(this.apiKey);
  TornApiCaller.items(this.apiKey);
  TornApiCaller.inventory(this.apiKey);
  TornApiCaller.education(this.apiKey);
  TornApiCaller.faction(this.apiKey, this.queryId);
  TornApiCaller.factionCrimes(this.apiKey);
  TornApiCaller.friends(this.apiKey, this.queryId);
  TornApiCaller.property(this.apiKey, this.queryId);
  TornApiCaller.stockmarket(this.apiKey);

  Future<dynamic> get getTravel async {
    dynamic apiResult;
    await _apiCall(ApiType.user, apiSelection: ApiSelection.travel).then((value) {
      apiResult = value;
    });
    if (apiResult is http.Response) {
      return TravelModel.fromJson(json.decode(apiResult.body));
    } else if (apiResult is ApiError) {
      return apiResult;
    }
  }

  Future<dynamic> get getProfileBasic async {
    dynamic apiResult;
    await _apiCall(ApiType.user, apiSelection: ApiSelection.ownBasic).then((value) {
      apiResult = value;
    });
    if (apiResult is http.Response) {
      return OwnProfileBasic.fromJson(json.decode(apiResult.body));
    } else if (apiResult is ApiError) {
      return apiResult;
    }
  }

  Future<dynamic> get getProfileExtended async {
    dynamic apiResult;
    await _apiCall(ApiType.user, apiSelection: ApiSelection.ownExtended, limit: limit).then((value) {
      apiResult = value;
    });
    if (apiResult is http.Response) {
      return OwnProfileExtended.fromJson(json.decode(apiResult.body));
    } else if (apiResult is ApiError) {
      return apiResult;
    }
  }

  Future<dynamic> get getProfileMisc async {
    dynamic apiResult;
    await _apiCall(ApiType.user, apiSelection: ApiSelection.ownMisc).then((value) {
      apiResult = value;
    });
    if (apiResult is http.Response) {
      return OwnProfileMisc.fromJson(json.decode(apiResult.body));
    } else if (apiResult is ApiError) {
      return apiResult;
    }
  }

  Future<dynamic> get getBazaar async {
    dynamic apiResult;
    await _apiCall(ApiType.user, apiSelection: ApiSelection.bazaar).then((value) {
      apiResult = value;
    });
    if (apiResult is http.Response) {
      return BazaarModel.fromJson(json.decode(apiResult.body));
    } else if (apiResult is ApiError) {
      return apiResult;
    }
  }

  Future<dynamic> get getOtherProfile async {
    dynamic apiResult;
    await _apiCall(ApiType.user, prefix: this.queryId, apiSelection: ApiSelection.otherProfile).then((value) {
      apiResult = value;
    });
    if (apiResult is http.Response) {
      return OtherProfileModel.fromJson(json.decode(apiResult.body));
    } else if (apiResult is ApiError) {
      return apiResult;
    }
  }

  Future<dynamic> get getTarget async {
    dynamic apiResult;
    await _apiCall(ApiType.user, prefix: this.queryId, apiSelection: ApiSelection.target).then((value) {
      apiResult = value;
    });
    if (apiResult is http.Response) {
      return TargetModel.fromJson(json.decode(apiResult.body));
    } else if (apiResult is ApiError) {
      return apiResult;
    }
  }

  Future<dynamic> get getAttacks async {
    dynamic apiResult;
    await _apiCall(ApiType.user, apiSelection: ApiSelection.attacks).then((value) {
      apiResult = value;
    });
    if (apiResult is http.Response) {
      return AttackModel.fromJson(json.decode(apiResult.body));
    } else if (apiResult is ApiError) {
      return apiResult;
    }
  }

  Future<dynamic> get getAttacksFull async {
    dynamic apiResult;
    await _apiCall(ApiType.user, apiSelection: ApiSelection.attacksFull).then((value) {
      apiResult = value;
    });
    if (apiResult is http.Response) {
      return AttackFullModel.fromJson(json.decode(apiResult.body));
    } else if (apiResult is ApiError) {
      return apiResult;
    }
  }

  Future<dynamic> get getChainStatus async {
    dynamic apiResult;
    await _apiCall(ApiType.faction, apiSelection: ApiSelection.chainStatus).then((value) {
      apiResult = value;
    });
    if (apiResult is http.Response) {
      try {
        return ChainModel.fromJson(json.decode(apiResult.body));
      } catch (e) {
        return ApiError();
      }
    } else if (apiResult is ApiError) {
      return apiResult;
    }
  }

  Future<dynamic> get getBars async {
    dynamic apiResult;
    await _apiCall(ApiType.user, apiSelection: ApiSelection.bars).then((value) {
      apiResult = value;
    });
    if (apiResult is http.Response) {
      try {
        return BarsModel.fromJson(json.decode(apiResult.body));
      } catch (e) {
        return ApiError();
      }
    } else if (apiResult is ApiError) {
      return apiResult;
    }
  }

  Future<dynamic> get getItems async {
    dynamic apiResult;
    await _apiCall(ApiType.torn, apiSelection: ApiSelection.items).then((value) {
      apiResult = value;
    });
    if (apiResult is http.Response) {
      try {
        return ItemsModel.fromJson(json.decode(apiResult.body));
      } catch (e) {
        return ApiError();
      }
    } else if (apiResult is ApiError) {
      return apiResult;
    }
  }

  Future<dynamic> get getInventory async {
    dynamic apiResult;
    await _apiCall(ApiType.user, apiSelection: ApiSelection.inventory).then((value) {
      apiResult = value;
    });
    if (apiResult is http.Response) {
      try {
        return InventoryModel.fromJson(json.decode(apiResult.body));
      } catch (e) {
        return ApiError();
      }
    } else if (apiResult is ApiError) {
      return apiResult;
    }
  }

  Future<dynamic> get getEducation async {
    dynamic apiResult;
    await _apiCall(ApiType.torn, apiSelection: ApiSelection.education).then((value) {
      apiResult = value;
    });
    if (apiResult is http.Response) {
      try {
        return TornEducationModel.fromJson(json.decode(apiResult.body));
      } catch (e) {
        return ApiError();
      }
    } else if (apiResult is ApiError) {
      return apiResult;
    }
  }

  Future<dynamic> get getFaction async {
    dynamic apiResult;
    await _apiCall(
      ApiType.faction,
      prefix: queryId,
      apiSelection: ApiSelection.faction,
    ).then((value) {
      apiResult = value;
    });
    if (apiResult is http.Response) {
      try {
        return FactionModel.fromJson(json.decode(apiResult.body));
      } catch (e) {
        return ApiError();
      }
    } else if (apiResult is ApiError) {
      return apiResult;
    }
  }

  Future<dynamic> get getFactionCrimes async {
    dynamic apiResult;
    await _apiCall(ApiType.faction, apiSelection: ApiSelection.factionCrimes).then((value) {
      apiResult = value;
    });
    if (apiResult is http.Response) {
      try {
        return FactionCrimesModel.fromJson(json.decode(apiResult.body));
      } catch (e) {
        return ApiError();
      }
    } else if (apiResult is ApiError) {
      return apiResult;
    }
  }

  Future<dynamic> get getFriends async {
    dynamic apiResult;
    await _apiCall(ApiType.user, prefix: this.queryId, apiSelection: ApiSelection.friends).then((value) {
      apiResult = value;
    });
    if (apiResult is http.Response) {
      try {
        return FriendModel.fromJson(json.decode(apiResult.body));
      } catch (e) {
        return ApiError();
      }
    } else if (apiResult is ApiError) {
      return apiResult;
    }
  }

  Future<dynamic> get getProperty async {
    dynamic apiResult;
    await _apiCall(ApiType.property, prefix: this.queryId, apiSelection: ApiSelection.property).then((value) {
      apiResult = value;
    });
    if (apiResult is http.Response) {
      try {
        return PropertyModel.fromJson(json.decode(apiResult.body));
      } catch (e) {
        return ApiError();
      }
    } else if (apiResult is ApiError) {
      return apiResult;
    }
  }

  Future<dynamic> get getAllStocks async {
    dynamic apiResult;
    await _apiCall(ApiType.torn, prefix: this.queryId, apiSelection: ApiSelection.stocks).then((value) {
      apiResult = value;
    });
    if (apiResult is http.Response) {
      try {
        return StockMarketModel.fromJson(json.decode(apiResult.body));
      } catch (e) {
        return ApiError();
      }
    } else if (apiResult is ApiError) {
      return apiResult;
    }
  }

  Future<dynamic> get getUserStocks async {
    dynamic apiResult;
    await _apiCall(ApiType.user, prefix: this.queryId, apiSelection: ApiSelection.stocks).then((value) {
      apiResult = value;
    });
    if (apiResult is http.Response) {
      try {
        return StockMarketUserModel.fromJson(json.decode(apiResult.body));
      } catch (e) {
        return ApiError();
      }
    } else if (apiResult is ApiError) {
      return apiResult;
    }
  }

  Future<dynamic> _apiCall(ApiType apiType,
      {String prefix, @required ApiSelection apiSelection, int limit = 100}) async {
    String url = 'https://api.torn.com/';
    switch (apiType) {
      case ApiType.user:
        url += 'user/';
        break;
      case ApiType.faction:
        url += 'faction/';
        break;
      case ApiType.torn:
        url += 'torn/';
        break;
      case ApiType.property:
        url += 'property/';
        break;
    }

    switch (apiSelection) {
      case ApiSelection.travel:
        url += '?selections=money,travel';
        break;
      case ApiSelection.ownBasic:
        url += '?selections=profile,battlestats';
        break;
      case ApiSelection.ownExtended:
        url += '?selections=profile,bars,networth,'
            'cooldowns,events,travel,icons,'
            'money,education,messages';
        break;
      case ApiSelection.ownMisc:
        url += '?selections=money,education,workstats,battlestats,jobpoints,properties,skills';
        break;
      case ApiSelection.bazaar:
        url += '?selections=bazaar';
        break;
      case ApiSelection.otherProfile:
        url += '$prefix?selections=profile,crimes,personalstats';
        break;
      case ApiSelection.target:
        url += '$prefix?selections=profile,discord';
        break;
      case ApiSelection.attacks:
        url += '$prefix?selections=attacks';
        break;
      case ApiSelection.attacksFull:
        url += '$prefix?selections=attacksfull';
        break;
      case ApiSelection.chainStatus:
        url += '?selections=chain';
        break;
      case ApiSelection.bars:
        url += '?selections=bars';
        break;
      case ApiSelection.items:
        url += '?selections=items';
        break;
      case ApiSelection.inventory:
        url += '?selections=inventory,display';
        break;
      case ApiSelection.education:
        url += '?selections=education';
        break;
      case ApiSelection.faction:
        url += '$prefix?selections=';
        break;
      case ApiSelection.factionCrimes:
        url += '?selections=crimes';
        break;
      case ApiSelection.friends:
        url += '$prefix?selections=profile,discord';
        break;
      case ApiSelection.property:
        url += '$prefix?selections=property';
        break;
      case ApiSelection.stocks:
        url += '$prefix?selections=stocks';
        break;
    }
    url += '&key=$apiKey&comment=PDA-App&limit=$limit';

    //url = 'http://www.google.com:81';  // DEBUG FOR TIMEOUT!
    //await new Future.delayed(const Duration(seconds : 5));  // DEBUG TIMEOUT 2
    try {
      final response = await http.get(Uri.parse(url)).timeout(Duration(seconds: 20));
      if (response.statusCode == 200) {
        // Check if json is responding with errors
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['error'] != null) {
          return ApiError(errorId: jsonResponse['error']['code']);
        }
        // Otherwise, return a good json response
        return response;
      } else {
        return ApiError(errorId: 0);
      }
    } on TimeoutException catch (_) {
      return ApiError(errorId: 100);
    } catch (_) {
      return ApiError(errorId: 0);
    }
  }
}
