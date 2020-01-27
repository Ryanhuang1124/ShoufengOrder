import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VoteStore {
  VoteStore(storeName) {
    this.storeName = storeName;
  }
  String storeName = '';
  int count = 0;
}

void uploadVoteStore(fireStore, String storeName) {
  fireStore
      .collection('Vote')
      .document('VoteStore')
      .setData({'$storeName': null}, merge: true);
}

void uploadVoteState(fireStore, bool state, String userName) {
  fireStore
      .collection('Vote')
      .document('VoteState')
      .setData({userName: state}, merge: false);
}

void uploadStoreSelect(fireStore, String userName, String storeName) {
  fireStore
      .collection('Vote')
      .document('storeSelect')
      .setData({userName: storeName}, merge: true);
}

void clearStoreSelect(fireStore) {
  fireStore.collection('Vote').document('storeSelect').delete();
}

void clearVoteStore(fireStore) {
  print('clear VoteStore Called');
  fireStore.collection('Vote').document('VoteStore').delete();
}

void uploadVoteTime(fireStore) {
  DateTime now = DateTime.now();
  String month = '';
  switch (now.month) {
    case 1:
      month = 'Jan';
      break;
    case 2:
      month = 'Feb';
      break;
    case 3:
      month = 'Mar';
      break;
    case 4:
      month = 'Apr';
      break;
    case 5:
      month = 'May';
      break;
    case 6:
      month = 'Jun';
      break;
    case 7:
      month = 'Jul';
      break;
    case 8:
      month = 'Aug';
      break;
    case 9:
      month = 'Feb';
      break;
    case 10:
      month = 'Oct';
      break;
    case 11:
      month = 'Nov';
      break;
    case 12:
      month = 'Dec';
      break;
  }

  fireStore.collection('Vote').document('VoteTime').setData({
    'year': now.year.toString(),
    'month': month,
    'day': (now.day < 10) ? '0${now.day}' : now.day.toString(),
    'hour': now.hour.toString(),
    'min': (now.minute < 10) ? '0${now.minute}' : now.minute.toString(),
  }, merge: false);
}
