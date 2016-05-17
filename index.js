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

function initPlayer(x, y, r, pointerLength) {
  changes.players = [
    ...G.players,
    {
      x,
      y,
      r,
      pointerLength
    }
  ];
}

function drawPlayer({x, y, r, pointerLength}, cursor) {
  // ctx.strokeRect(x,y,w,h);

  ctx.beginPath();
  ctx.arc(x, y, r, 0, 2 * Math.PI);
  ctx.stroke();

  function getPointer() {
    let bigPointerX = cursor.x - x;
    let bigPointerY = cursor.y - y;

    let bigC = Math.sqrt(Math.pow(bigPointerY, 2) + Math.pow(bigPointerX, 2));

    return {
      x: x + (pointerLength * (bigPointerX / bigC)),
      y: y + (pointerLength * (bigPointerY / bigC))
    }
  }
  let pointerCoords = getPointer();

  ctx.beginPath();
  ctx.arc(pointerCoords.x, pointerCoords.y, 3, 0, 2 * Math.PI);
  ctx.fill();
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
  // drawCursor();
  drawPlayers();
  // ctx.strokeRect(135,135,30,30);
}

function init() {
  initPlayer(150,150,30,60);

  document.addEventListener('mousemove', changeCursor);

  requestAnimationFrame(render);
}

//------------------------------------------------------------------------------

init();
