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

import 'package:flutter/material.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';

import '../../data/services/note_rest_services.dart';

class NotesWidget extends StatefulWidget {
  final String? patientId;

  const NotesWidget({super.key, this.patientId});

  @override
  _NotesState createState() => _NotesState();
}

class _NotesState extends State<NotesWidget> {
  static const _secondsDelay = 3;
  static const _sendingMessage = "Sending...";
  late Future<bool> _futureSendState;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _isIncludeAlert = true;
  String _noteStatusMessage = "";
  Color _notesStatusColor = Colors.red;
  final String _sendNoteButtonLabel = "Send Note";
  bool _sendButtonEnabled = true;
  bool _delaying = false;
  bool _textsEnabled = false;

  @override
  void initState() {
    super.initState();
    _futureSendState = sendNote(null, patientId: widget.patientId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: _futureSendState,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          _updateStateVars(snapshot);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                const MmsText('Title:  ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 14)),
                SizedBox(
                    width: 150,
                    height: 30,
                    child: Align(
                      alignment: Alignment.center,
                      child: TextField(
                          controller: _titleController,
                          enabled: _textsEnabled,
                          onChanged: (value) {
                            if (_noteStatusMessage != "") {
                              setState(() {
                                _noteStatusMessage = "";
                              });
                            }
                          },
                          style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                              fontSize: 12),
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1, color: Colors.grey)))),
                    ))
              ]),
              const MmsText('Body:  ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 14)),
              TextField(
                  controller: _noteController,
                  enabled: _textsEnabled,
                  onChanged: (value) {
                    if (_noteStatusMessage != "") {
                      setState(() {
                        _noteStatusMessage = "";
                      });
                    }
                  },
                  maxLines: 4,
                  style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                      fontSize: 12),
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 1, color: Colors.grey)))),
              Row(
                children: [
                  Checkbox(
                    value: _isIncludeAlert,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _isIncludeAlert = value;
                        });
                      }
                    },
                  ),
                  const MmsText('Include Alert',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 14)),
                  Expanded(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: (_noteStatusMessage == _sendingMessage
                                ? const Center(
                                    child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator()))
                                : MmsText(_noteStatusMessage,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _notesStatusColor,
                                        fontSize: 14)))),
                        ElevatedButton(
                          onPressed: _sendButtonEnabled
                              ? () {
                                  setState(() {
                                    _futureSendState = sendNote(
                                        Note(
                                            _titleController.text,
                                            _noteController.text,
                                            _isIncludeAlert),
                                        patientId: widget.patientId);
                                    _sendButtonEnabled = false;
                                    _noteStatusMessage = "";
                                  });
                                }
                              : null,
                          child: MmsText(_sendNoteButtonLabel),
                        )
                      ])),
                ],
              )
            ],
          );
        });
  }

  void _updateStateVars(AsyncSnapshot<bool> snapshot) {
    if (snapshot.connectionState == ConnectionState.active ||
        snapshot.connectionState == ConnectionState.waiting) {
      _noteStatusMessage = _sendingMessage;
      _notesStatusColor = Colors.black;
      _sendButtonEnabled = false;
    } else if (snapshot.hasError) {
      _failedStatus();
    } else if (!snapshot.hasData) {
      _noteStatusMessage = "";
      _sendButtonEnabled = !_delaying;
    } else if (snapshot.data!) {
      _noteStatusMessage = _sendButtonEnabled ? "" : "Sent";
      _notesStatusColor = Colors.green;
      if (!_delaying && !_sendButtonEnabled) {
        _titleController.text = "";
        _noteController.text = "";
      }
      _sendButtonEnabled = _delayButtonEnabled();
    } else {
      _failedStatus();
    }
    _textsEnabled = _sendButtonEnabled || _delaying;
  }

  void _failedStatus() {
    _noteStatusMessage = _sendButtonEnabled ? "" : "Failed";
    _notesStatusColor = Colors.red;
    _sendButtonEnabled = !_delaying;
  }

  bool _delayButtonEnabled() {
    if (_delaying) {
      return false;
    }
    if (!_sendButtonEnabled) {
      _delaying = true;
      Future.delayed(const Duration(seconds: _secondsDelay), () {
        if (mounted) {
          setState(() {
            _sendButtonEnabled = true;
            _delaying = false;
          });
        }
      });
    }
    return _sendButtonEnabled;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
