var canvas = document.querySelector('#c');
var ctx = canvas.getContext('2d');

var G = {
  player: {},
  // newPlayerId: 0,
  cursor: {
    x: -10,
    y: -10
  }
};

var changes = {};

//------------------------------------------------------------------------------

function initPlayer(x = 150, y = 150, r = 10, pointerLength = 30) {
  let player = {
    x,
    y,
    r,
    vector: {x: 0, y: 0},
    pointerLength
  };

  changes = Object.assign({}, changes, {player});
}

function drawPlayer({x, y, r, pointerLength, vector}, cursor) {
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
  drawPlayer(G.player, G.cursor);
}

//------------------------------------------------------------------------------
// CHANGES
function changeCursor(e) {
  changes.cursor = {
    x: e.clientX,
    y: e.clientY
  };
}

function changePlayerVector(vector) {
  let player = Object.assign({}, changes.player, {vector: Object.assign({}, changes.player.vector, vector)});

  changes = Object.assign({}, changes, player);
}

function startMovePlayer(e) {
  switch (e.which) {
    case 87:
      changePlayerVector({y: 10});
    break;

    case 83:
      changePlayerVector({y: -10});
    break;

    case 68:
      changePlayerVector({x: 10});
    break;

    case 65:
      changePlayerVector({x: -10});
  }
}

function stopMovePlayer(e) {
  switch (e.which) {
    case 87:
      changePlayerVector({y: 0});
    break;

    case 83:
      changePlayerVector({y: 0});
    break;

    case 68:
      changePlayerVector({x: 0});
    break;

    case 65:
      changePlayerVector({x: 0});
  }
}

function movePlayer() {
  let newCoords = {
    x: changes.player.x + changes.player.vector.x,
    y: changes.player.y + changes.player.vector.y
  };

  changes = Object.assign(
    {},
    changes,
    {player:
      Object.assign(
        {},
        changes.player,
        newCoords
      )}
  );
}

//------------------------------------------------------------------------------

function render() {
  commitChanges();
  clearCanvas();
  draw();

  requestAnimationFrame(render);
}

function commitChanges() {
  movePlayer();
  G = Object.assign({}, G, changes);
  changes = Object.assign({}, G);
}

function clearCanvas() {
  ctx.clearRect(0,0,300,300);
}

function draw() {
  drawPlayers();
}

function init() {
  initPlayer(150,150,10,30);

  document.addEventListener('mousemove', changeCursor);
  document.addEventListener('keydown', startMovePlayer);
  document.addEventListener('keyup', stopMovePlayer);

  requestAnimationFrame(render);
}

//------------------------------------------------------------------------------

init();
