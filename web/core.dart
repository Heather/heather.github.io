import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';

import 'package:dquery/dquery.dart';
import 'package:bootjack/bootjack.dart';

void main() {
    Bootjack.useDefault();
    applicationFactory().run();
}
