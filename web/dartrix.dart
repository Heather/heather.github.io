library dartrix;

import 'dart:html';
import 'dart:math';

// Original code from : https://github.com/hendo13/HTML5-Matrix-Code-Rain

void main() {
    new Dartrix().run();
}

final num _STRIP_NUMBER = 21;
final String MESSAGE = "Mi Mi Mi";
final num MESSAGE_DELAY = 5000;
final List<String> _COLORS = const ['#FA14A7', '#FAFFFF', '#FAA2FA', '#D19DCD', '#F9A0AA', "#FAFFFA"];

final List<String> _SYMBOLS = const [ 'main :: IO ()'
                                    , 'posts <- rcF =<< loadAll "posts/*"'
                                    , 'create ["index.html"]'
                                    , '>>= loadAndApplyTemplate "default.html" homeCtx'
                                    , 'create ["index.html"]'
                                    , 'div # "#header" ? do marginBottom (px 44)'
                                    , '>>='
                                    , '>>'
                                    , '<|>'
                                    , 'map', 'filter', 'fold', 'case', 'match'
                                    ];

class Dartrix {
    CanvasElement _canvas;
    CanvasRenderingContext2D _ctx;
    num _height;
    num _width;

    List<num> _stripFontSize;
    List<num> _stripX;
    List<num> _stripY;
    List<num> _dY;

    final Random _randommer;
    num _startTime;

    Dartrix() : _randommer = new Random(); 

    initStrips() {
        _stripFontSize = new List<num>(_STRIP_NUMBER);
        _stripX = new List<num>(_STRIP_NUMBER);
        _stripY = new List<num>(_STRIP_NUMBER);
        _dY = new List<num>(_STRIP_NUMBER);
        for (var i = 0; i < _STRIP_NUMBER; i++) {
            initStrip(i);
        }
    }
  
    initStrip(num i){
        _stripX[i] = _randommer.nextDouble() * _width;
        _stripY[i] = -100;
        _dY[i] = _randommer.nextDouble()*7 + 3;
        _stripFontSize[i] = _randommer.nextInt(24) + 12;   
    }
  
    void draw(num time){
        clear();
        if(_startTime == null){
            _startTime = time;
        } else if((time - _startTime)<MESSAGE_DELAY){
            var remainingTime = MESSAGE_DELAY - (time - _startTime);
            var alpha = remainingTime/MESSAGE_DELAY;
            showMessage(alpha);
        }
        for(var i=0; i<_STRIP_NUMBER; i++) {
            var size = _stripFontSize[i];
            _ctx..font = '${size}px MatrixCode'
                ..textBaseline = 'top'
                ..textAlign = 'center';
            if (_stripY[i] > _height) { initStrip(i);
            } else {                    drawStrip(_stripX[i], _stripY[i]);
            }
            _stripY[i] += _dY[i];      
        }
        window.animationFrame.then(draw);
    }
  
    clear(){
        _ctx..clearRect(0, 0, _canvas.width, _canvas.height)
            ..shadowOffsetX = _ctx.shadowOffsetY = 0
            ..shadowBlur    = 8
            ..shadowColor   = '#94f475';
    }
  
    drawStrip(x, y) {
        for (var k = 0; k <= 20; k++) {
            var randCat = _SYMBOLS[_randommer.nextInt(_SYMBOLS.length-1)];
            var color;
            switch (k) {
                case 0: color = _COLORS[0]; break;
                case 1: color = _COLORS[1]; break;
                case 3: color = _COLORS[2]; break;
                case 7: color = _COLORS[3]; break;
                case 13:color = _COLORS[4]; break;
                case 17:color = _COLORS[5]; break;
            }
            _ctx..fillStyle = color
                ..fillText(randCat, x, y);
            y -= _stripFontSize[k];
        }
    }
  
    showMessage(double alpha){
        _ctx..font = 'bold 75px Verdana'
            ..fillStyle = 'rgba(67,199,40, ${alpha})'
            ..fillText(MESSAGE , _width/2+100, _height/2);
    }

    onResize() {
        _canvas..height = _height = window.innerHeight
               ..width  = _width  = _canvas.width = window.innerWidth;
    }  
  
    run(){
        _canvas = document.querySelector("#canvas");
        _ctx    = _canvas.context2D;
        onResize();
        initStrips();
        window..onResize.listen((event) => onResize())
              ..animationFrame.then(draw);
    }
}
