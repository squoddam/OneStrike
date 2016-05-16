var canvas = document.querySelector('#c');
var ctx = canvas.getContext('2d');
// var players = [];

var G = {
  players: [],
  cursor: {
    x: -10,
    y: -10
  }
};

var changes = {};

//------------------------------------------------------------------------------

function initPlayer(x, y, side) {
  changes.players = [
    ...G.players,
    {
      x,
      y,
      w: side,
      h: side,
      ponter: 0,
      pointerLength: 30
    }
  ];
}

function drawPlayer({x,y,w,h, pointer, pointerLength}, cursor) {
  ctx.strokeRect(x,y,w,h);

  let pc = {
    x: x + w / 2,
    y: y + h / 2
  };

  function getPointer() {
    let bigPointerX = cursor.x - pc.x;
    let bigPointerY = cursor.y - pc.y;

    let bigC = Math.sqrt(Math.pow(bigPointerY, 2) + Math.pow(bigPointerX, 2));

    return {
      x: pc.x + (pointerLength * (bigPointerX / bigC)),
      y: pc.y + (pointerLength * (bigPointerY / bigC))
    }
  }
  let pointerCoords = getPointer();

  ctx.beginPath();
  ctx.moveTo(pc.x, pc.y);
  ctx.lineTo(pointerCoords.x, pointerCoords.y);
  ctx.stroke();
}

function drawPlayers() {
  G.players.forEach(p => drawPlayer(p, G.cursor));
}

//------------------------------------------------------------------------------

function changeCursor(e) {
  changes.cursor = {
    x: e.clientX,
    y: e.clientY
  };
}

function drawCursor() {
  ctx.strokeRect(G.cursor.x, G.cursor.y, 10, 10);
}

//------------------------------------------------------------------------------

function render() {
  commitChanges();
  clearCanvas();
  draw();

  requestAnimationFrame(render);
}

function commitChanges() {
  G = Object.assign({}, G, changes);
  changes = {};
}

function clearCanvas() {
  ctx.clearRect(0,0,300,300);
}

function draw() {
  drawCursor();
  drawPlayers();
  // ctx.strokeRect(135,135,30,30);
}

function init() {
  initPlayer(135,135,30,30);

  document.addEventListener('mousemove', changeCursor);

  requestAnimationFrame(render);
}

//------------------------------------------------------------------------------

init();
