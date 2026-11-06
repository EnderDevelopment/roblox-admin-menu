const app = document.getElementById('app');
const playerList = document.getElementById('player-list');
const searchInput = document.getElementById('search');
const selectedDetails = document.getElementById('selected-details');
const details = document.getElementById('details');
const emptyState = document.getElementById('empty');
let players = [];
let selectedId = null;
let frozenIds = new Set();
let pendingAction = null;

function post(endpoint, data = {}) {
  return fetch(`https://${GetParentResourceName()}/${endpoint}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(data)
  }).catch(() => {});
}

function escapeHtml(value) {
  return String(value).replace(/[&<>"']/g, char => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[char]);
}

function renderPlayers() {
  const query = searchInput.value.trim().toLowerCase();
  const filtered = players.filter(player => String(player.name).toLowerCase().includes(query) || String(player.id).includes(query));
  document.getElementById('player-count').textContent = players.length;
  document.getElementById('online-label').innerHTML = `<i></i> ${players.length} ONLINE`;
  playerList.innerHTML = filtered.map(player => `
    <button class="player-row ${Number(player.id) === Number(selectedId) ? 'selected' : ''}" data-id="${Number(player.id)}">
      <span class="player-main"><span class="mini-avatar">${escapeHtml(String(player.name).trim().charAt(0).toUpperCase() || '?')}</span><span><span class="player-name">${escapeHtml(player.name)}</span><span class="player-id">ID ${Number(player.id)}</span></span></span>
      <span class="ping">${Number(player.ping) || 0} ms</span>
    </button>`).join('');
  emptyState.classList.toggle('show', filtered.length === 0);
  playerList.querySelectorAll('.player-row').forEach(row => row.addEventListener('click', () => selectPlayer(Number(row.dataset.id))));
  if (selectedId !== null && !players.some(player => Number(player.id) === Number(selectedId))) clearSelection();
}

function selectPlayer(id) {
  const player = players.find(item => Number(item.id) === Number(id));
  if (!player) return;
  selectedId = Number(id);
  details.classList.remove('empty-details');
  document.querySelector('.detail-placeholder').classList.add('hidden');
  selectedDetails.classList.remove('hidden');
  document.getElementById('avatar').textContent = String(player.name).trim().charAt(0).toUpperCase() || '?';
  document.getElementById('selected-name').textContent = player.name;
  document.getElementById('selected-id').textContent = player.id;
  updateFreezeButton();
  renderPlayers();
}

function clearSelection() {
  selectedId = null;
  selectedDetails.classList.add('hidden');
  document.querySelector('.detail-placeholder').classList.remove('hidden');
  details.classList.add('empty-details');
}

function updateFreezeButton() {
  const isFrozen = frozenIds.has(Number(selectedId));
  document.getElementById('freeze-label').textContent = isFrozen ? 'Unfreeze' : 'Freeze';
  document.getElementById('freeze-button').classList.toggle('frozen', isFrozen);
}

function showToast(message, kind = 'info') {
  const toast = document.createElement('div');
  toast.className = `toast ${kind}`;
  toast.textContent = message;
  document.getElementById('toast-region').appendChild(toast);
  setTimeout(() => toast.remove(), 3600);
}

function actionNeedsConfirm(action) {
  return action === 'kick' || action === 'bring' || action === 'revive';
}

function runAction(action) {
  if (selectedId === null) return;
  const reason = document.getElementById('reason').value.trim();
  const data = { action, id: selectedId, reason };
  if (action === 'freeze') {
    data.enabled = !frozenIds.has(Number(selectedId));
    if (data.enabled) frozenIds.add(Number(selectedId)); else frozenIds.delete(Number(selectedId));
    updateFreezeButton();
  }
  post('action', data);
}

function askConfirm(action) {
  const player = players.find(item => Number(item.id) === Number(selectedId));
  if (!player) return;
  pendingAction = action;
  const messages = {
    kick: ['Kick player?', `Remove ${player.name} [${player.id}] from the server?`],
    bring: ['Bring player?', `Move ${player.name} [${player.id}] to your location?`],
    revive: ['Revive player?', `Revive ${player.name} [${player.id}]?`]
  };
  const [title, message] = messages[action];
  document.getElementById('confirm-title').textContent = title;
  document.getElementById('confirm-message').textContent = message;
  document.getElementById('confirm').classList.remove('hidden');
}

function setView(view) {
  document.querySelectorAll('.nav-item').forEach(item => item.classList.toggle('active', item.dataset.view === view));
  document.getElementById('players-view').classList.toggle('hidden', view !== 'players');
  document.getElementById('announce-view').classList.toggle('hidden', view !== 'announce');
}

document.getElementById('close').addEventListener('click', () => post('close'));
document.getElementById('refresh').addEventListener('click', () => post('refresh'));
document.getElementById('cancel-confirm').addEventListener('click', () => {
  document.getElementById('confirm').classList.add('hidden');
  pendingAction = null;
});
document.getElementById('accept-confirm').addEventListener('click', () => {
  if (pendingAction) runAction(pendingAction);
  document.getElementById('confirm').classList.add('hidden');
  pendingAction = null;
});
searchInput.addEventListener('input', renderPlayers);
document.querySelectorAll('.nav-item').forEach(item => item.addEventListener('click', () => setView(item.dataset.view)));
document.querySelectorAll('.action-button, #kick-button').forEach(button => button.addEventListener('click', () => {
  if (actionNeedsConfirm(button.dataset.action)) askConfirm(button.dataset.action);
  else runAction(button.dataset.action);
}));
const announcementInput = document.getElementById('announcement');
announcementInput.addEventListener('input', () => {
  document.getElementById('char-count').textContent = `${announcementInput.value.length} / 180`;
});
document.getElementById('send-announcement').addEventListener('click', () => {
  const message = announcementInput.value.trim();
  if (!message) return showToast('Enter an announcement first.', 'error');
  post('action', { action: 'announce', message });
  announcementInput.value = '';
  document.getElementById('char-count').textContent = '0 / 180';
});
document.addEventListener('keydown', event => {
  if (event.key === 'Escape') {
    if (!document.getElementById('confirm').classList.contains('hidden')) {
      document.getElementById('confirm').classList.add('hidden');
      pendingAction = null;
    } else if (!app.classList.contains('hidden')) post('close');
  }
});

window.addEventListener('message', event => {
  const data = event.data || {};
  if (data.type === 'open') {
    app.classList.remove('hidden');
    players = Array.isArray(data.players) ? data.players : [];
    clearSelection();
    renderPlayers();
    setView('players');
  } else if (data.type === 'close') {
    app.classList.add('hidden');
    document.getElementById('confirm').classList.add('hidden');
  } else if (data.type === 'players') {
    players = Array.isArray(data.players) ? data.players : [];
    renderPlayers();
  } else if (data.type === 'toast') {
    showToast(data.message || '', data.kind || 'info');
  } else if (data.type === 'announcement') {
    document.getElementById('banner-sender').textContent = data.sender || 'Admin';
    document.getElementById('banner-message').textContent = data.message || '';
    const banner = document.getElementById('announcement-banner');
    banner.classList.remove('hidden');
    setTimeout(() => banner.classList.add('hidden'), 8000);
  }
});
