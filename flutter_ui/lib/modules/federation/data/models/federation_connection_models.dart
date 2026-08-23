/*
 * Copyright 2026 IVIR Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:collection';
import 'package:flutter_ui/logic/utils/connector_status.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class FederationConnectionModel extends Equatable {
  static const FederationConnectionModel autoDisconnected =
      FederationConnectionModel(
          null, null, ConnectorStatus.disconnectedKey, null);
  final String? federateName;
  final String? federationName;
  final String? status;
  final String? message;
  const FederationConnectionModel(
      this.federateName, this.federationName, this.status, this.message);

  /// Copy a model, but substituting any specified parts.
  factory FederationConnectionModel.copy(FederationConnectionModel? model,
      {String? federateName,
      String? federationName,
      String? status,
      String? message}) {
    return FederationConnectionModel(
        federateName ?? model?.federateName,
        federationName ?? model?.federationName,
        status ?? model?.status,
        message ?? model?.message);
  }

  factory FederationConnectionModel.fromJson(Map<String, dynamic> json) {
    return FederationConnectionModel(json['federateName'],
        json['federationName'], json['status'], json['message']);
  }

  @override
  List<Object?> get props => [
        federateName,
        federationName,
        status,
      ];

  ConnectorStatus? get connectorStatus => ConnectorStatus.ofType(status);
}

class ConnectorConnectionModel extends Equatable {
  final String? name;
  final String? host;
  final String? port;
  final String? status;
  final String? message;
  const ConnectorConnectionModel(
      this.name, this.host, this.port, this.status, this.message);

  /// Copy a model, but substituting any specified parts.
  factory ConnectorConnectionModel.copy(ConnectorConnectionModel model,
      {String? name,
      String? host,
      String? port,
      String? status,
      String? message}) {
    return ConnectorConnectionModel(name ?? model.name, host ?? model.host,
        port ?? model.port, status ?? model.status, message ?? model.message);
  }

  factory ConnectorConnectionModel.fromJson(Map<String, dynamic> json) {
    return ConnectorConnectionModel(json['name'], json['host'],
        "${json['port']}", json['status'], json['message']);
  }
  factory ConnectorConnectionModel.errorStatus(String name) {
    return ConnectorConnectionModel(
        name, null, null, ConnectorStatus.error.statusLabel, null);
  }

  ConnectorStatus? get connectorStatus => ConnectorStatus.ofType(status);

  @override
  List<Object?> get props => [
        name,
        host,
        port,
        status,
      ];

  @override
  bool get stringify => true;
}

class FederationComboModel extends Equatable {
  static final FederationComboModel defErrorModel = FederationComboModel(
      const FederationConnectionModel(null, null, null, null), const {},
      isError: true);
  static const String truMonitorName = "TruMonitor";
  static const String enduvoName = "Enduvo";
  static const String simScopeName = "SimScope";
  static const String pumpControlName = "PumpControl";
  final FederationConnectionModel federationConnectionModel;
  final bool? isError;
  final Map<String, ConnectorConnectionModel> _connectorMappings = {};

  FederationComboModel(
    this.federationConnectionModel,
    Map<String, ConnectorConnectionModel> connectorMappings, {
    this.isError = false,
  }) {
    connectorMappings.forEach((key, value) {
      _connectorMappings[key] = ConnectorConnectionModel.copy(value);
    });
  }

  factory FederationComboModel.byPosition(
      FederationConnectionModel federationConnectionModel,
      ConnectorConnectionModel truMonitor,
      ConnectorConnectionModel enduvo,
      ConnectorConnectionModel simScope,
      ConnectorConnectionModel pumpControl,
      {bool isError = false}) {
    Map<String, ConnectorConnectionModel> connectorMappings =
        <String, ConnectorConnectionModel>{
      truMonitorName: truMonitor,
      enduvoName: enduvo,
      simScopeName: simScope,
      pumpControlName: pumpControl,
    };
    return FederationComboModel(federationConnectionModel, connectorMappings,
        isError: isError);
  }

  /// Copy a model, but substituting any specified parts.
  factory FederationComboModel.copy(FederationComboModel? model,
      {FederationConnectionModel? federationConnectionModel,
      Map<String, ConnectorConnectionModel>? connectorMappings,
      bool? isError}) {
    return FederationComboModel(
        federationConnectionModel ??
            FederationConnectionModel.copy(model?.federationConnectionModel),
        connectorMappings ?? model?._connectorMappings ?? {},
        isError: isError ?? model?.isError);
  }

  factory FederationComboModel.fromJson(Map<String, dynamic> json) {
    FederationConnectionModel fedData =
        FederationConnectionModel.fromJson(json['federation']);
    List<dynamic> connectorsList = json['connectors'];
    Map<String, ConnectorConnectionModel> models =
        <String, ConnectorConnectionModel>{};
    for (Map<String, dynamic> connectorData in connectorsList) {
      String connectorName = connectorData['name'];
      ConnectorConnectionModel model =
          ConnectorConnectionModel.fromJson(connectorData);
      models[connectorName] = model;
    }
    return FederationComboModel(fedData, models);
  }

  ConnectorConnectionModel? connectorData(String name) {
    return _connectorMappings[name];
  }

  void putConnectorData(String name, ConnectorConnectionModel model) {
    _connectorMappings[name] = model;
  }

  ConnectorConnectionModel? get truMonitor => connectorData(truMonitorName);
  ConnectorConnectionModel? get enduvo => connectorData(enduvoName);
  ConnectorConnectionModel? get simScope => connectorData(simScopeName);
  ConnectorConnectionModel? get pumpControl => connectorData(pumpControlName);

  @override
  List<Object?> get props =>
      [federationConnectionModel, isError, _connectorMappings];
}

class FederatesModel extends Equatable {
  static final FederatesModel defErrorModel =
      FederatesModel(null, const [], null, isError: true);

  final String? simTime;
  final List<String> _federates = [];
  final String? message;
  final bool isError;
  FederatesModel(this.simTime, List<String> federates, this.message,
      {this.isError = false}) {
    for (var element in federates) {
      _federates.add(element);
    }
  }

  /// Copy a model, but substituting any specified parts.
  factory FederatesModel.copy(FederatesModel? model,
      {String? simTime,
      List<String>? federates,
      String? message,
      bool? isError}) {
    return FederatesModel(simTime ?? model?.simTime,
        federates ?? model?.federates ?? [], message ?? model?.message,
        isError: isError ?? model?.isError ?? false);
  }

  factory FederatesModel.fromJson(Map<String, dynamic> json,
      {bool isError = false}) {
    String localSimTime = json["simTime"] ?? "";
    List<String> localFederates = List<String>.from(json["federates"] ?? "[]");
    String localMessage = json["message"] ?? "";
    return FederatesModel(localSimTime, localFederates, localMessage,
        isError: isError);
  }

  UnmodifiableListView<String> get federates =>
      UnmodifiableListView(_federates);

  int get federatesCount => _federates.length;

  @override
  List<Object?> get props => [simTime, federates, isError];
}

class FederationInfo extends Equatable {
  final FederationComboModel? _comboModel;
  final FederatesModel? _federatesModel;

  FederationInfo(
      FederationComboModel? comboModel, FederatesModel? federatesModel)
      : _comboModel =
            comboModel != null ? FederationComboModel.copy(comboModel) : null,
        _federatesModel =
            federatesModel != null ? FederatesModel.copy(federatesModel) : null;

  FederationComboModel? get comboModel => _comboModel;
  FederatesModel? get federatesModel => _federatesModel;

  @override
  List<Object?> get props => [_comboModel, _federatesModel];
}

class FederationInfoStore extends ChangeNotifier {
  FederationComboModel? _comboModel;
  FederatesModel? _federatesModel;

  FederationInfoStore._private();

  static final FederationInfoStore _instance = FederationInfoStore._private();

  factory FederationInfoStore() => _instance;

  void loadFederationComboModelFromJson(Map<String, dynamic> json) {
    FederationComboModel comboModelFromJson =
        FederationComboModel.fromJson(json);
    bool hasChanges = comboModelFromJson != _comboModel;
    if (hasChanges) {
      _comboModel = comboModelFromJson;
      notifyListeners();
    }
  }

  void loadFederationConnectionModelFromJson(Map<String, dynamic> json) {
    FederationConnectionModel modelFromJson =
        FederationConnectionModel.fromJson(json);
    bool hasChanges = _comboModel?.federationConnectionModel != modelFromJson;
    if (hasChanges) {
      _comboModel = FederationComboModel(
        modelFromJson,
        _comboModel?._connectorMappings ?? {},
        isError: _comboModel?.isError ?? true,
      );

      if (modelFromJson.connectorStatus == ConnectorStatus.disconnected) {
        _federatesModel = FederatesModel("", [], null);
      }

      notifyListeners();
    }
  }

  void loadFederatesModelFromJson(Map<String, dynamic> json) {
    bool hasChanges = false;
    FederatesModel federatesModelFromJson = FederatesModel.fromJson(json);
    hasChanges = federatesModelFromJson != _federatesModel;
    if (hasChanges) {
      _federatesModel = federatesModelFromJson;
      notifyListeners();
    }
  }

  void loadConnectorConnectionModelFromJson(
      String name, Map<String, dynamic> json) {
    ConnectorConnectionModel? prevModel = _comboModel?.connectorData(name);
    ConnectorConnectionModel connectorConnectionModel =
        ConnectorConnectionModel.fromJson(json);
    bool hasChanges = connectorConnectionModel != prevModel;
    if (hasChanges) {
      _comboModel?.putConnectorData(name, connectorConnectionModel);
      notifyListeners();
    }
  }

  void connectorConnectionError(String name) {
    ConnectorConnectionModel? prevModel = _comboModel?.connectorData(name);
    ConnectorConnectionModel errorModel =
        ConnectorConnectionModel.errorStatus(name);
    bool hasChanges = errorModel != prevModel;
    if (hasChanges) {
      _comboModel?.putConnectorData(name, errorModel);
      notifyListeners();
    }
  }

  void federatesModelError() {
    bool hasChanges = _federatesModel != FederatesModel.defErrorModel;
    if (hasChanges) {
      _federatesModel = FederatesModel.defErrorModel;
      notifyListeners();
    }
  }

  void federationComboModelError() {
    bool hasChanges = _comboModel != FederationComboModel.defErrorModel;
    if (hasChanges) {
      _comboModel = FederationComboModel.defErrorModel;
      notifyListeners();
    }
  }

  void federationComboModelAutoDisconnect() {
    FederationConnectionModel autoDisconnect =
        FederationConnectionModel.autoDisconnected;
    FederationConnectionModel? prevModel =
        _comboModel?.federationConnectionModel;
    bool hasChanges = autoDisconnect != prevModel;
    if (hasChanges) {
      _comboModel = FederationComboModel.copy(_comboModel!,
          federationConnectionModel: autoDisconnect);
      notifyListeners();
    }
  }

  FederationInfo get federationInfo =>
      FederationInfo(_comboModel, _federatesModel);

  FederationComboModel get federationComboModel =>
      FederationComboModel.copy(_comboModel);
  FederatesModel get federatesModel => FederatesModel.copy(_federatesModel);
  FederationConnectionModel get federationConnectionModel =>
      FederationConnectionModel.copy(_comboModel?.federationConnectionModel);

  FederationConnectionModel? get _federationConnectionModel =>
      _comboModel?.federationConnectionModel;

  String? get federateName => _federationConnectionModel?.federateName;
  String? get federationName => _federationConnectionModel?.federationName;
  ConnectorStatus? get federationConnectionStatus =>
      ConnectorStatus.ofType(_federationConnectionModel?.status);
  ConnectorConnectionModel? get truMonitor => _comboModel?.truMonitor;
  ConnectorConnectionModel? get enduvo => _comboModel?.enduvo;
  ConnectorConnectionModel? get simScope => _comboModel?.simScope;
  ConnectorConnectionModel? get pumpControl => _comboModel?.pumpControl;
  ConnectorConnectionModel connectorConnectionModel(String name) =>
      (_comboModel?._connectorMappings ?? {})[name] ??
      const ConnectorConnectionModel(null, null, null, null, null);

  int? get federatesCount => _federatesModel?.federatesCount;
}

class FederationInfoStoreAccess extends ChangeNotifier {
  static final FederationInfoStoreAccess _instance =
      FederationInfoStoreAccess._internal();

  factory FederationInfoStoreAccess() => _instance;

  FederationInfoStoreAccess._internal() {
    store.addListener(notifyListeners);
  }

  final FederationInfoStore store = FederationInfoStore();

  @override
  void dispose() {
    store.removeListener(notifyListeners);
    super.dispose();
  }

  void loadFederationComboModelFromJson(Map<String, dynamic> json) =>
      store.loadFederationComboModelFromJson(json);

  void loadFederationConnectionModelFromJson(Map<String, dynamic> json) =>
      store.loadFederationConnectionModelFromJson(json);

  void loadFederatesModelFromJson(Map<String, dynamic> json) =>
      store.loadFederatesModelFromJson(json);

  void loadConnectorConnectionModelFromJson(
          String name, Map<String, dynamic> json) =>
      store.loadConnectorConnectionModelFromJson(name, json);

  void connectorConnectionError(String name) =>
      store.connectorConnectionError(name);

  void federatesModelError() => store.federatesModelError();

  void federationComboModelError() => store.federationComboModelError();

  void federationComboModelAutoDisconnect() =>
      store.federationComboModelAutoDisconnect();

  void clearFederates() {
    store._federatesModel = FederatesModel(null, const [], null);
    notifyListeners();
  }

  FederationInfo get federationInfo => store.federationInfo;

  FederationComboModel get federationComboModel => store.federationComboModel;
  FederationConnectionModel get federationConnectionModel =>
      store.federationConnectionModel;
  String? get federateName => store.federateName;
  String? get federationName => store.federationName;
  ConnectorStatus? get federationConnectionStatus =>
      store.federationConnectionStatus;
  ConnectorConnectionModel? get truMonitor => store.truMonitor;
  ConnectorConnectionModel? get enduvo => store.enduvo;
  ConnectorConnectionModel? get simScope => store.simScope;
  ConnectorConnectionModel? get pumpControl => store.pumpControl;
  ConnectorConnectionModel connectorConnectionModel(String name) =>
      store.connectorConnectionModel(name);
  int? get federatesCount => store.federatesCount;

  FederatesModel get federatesModel => store.federatesModel;
}

class FederationActionModel {
  final String? action;
  final bool? status;
  final String? message;
  final bool? isError;
  FederationActionModel(this.action, this.status, this.message,
      {this.isError = false});
  factory FederationActionModel.fromJson(Map<String, dynamic> json,
      {bool? isError}) {
    return FederationActionModel(
        json['action'], json['status'], json['message'],
        isError: isError);
  }

  bool get hasIssue => isError ?? false || !(status ?? true);
}
