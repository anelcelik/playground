from flask import Flask, request, jsonify
import sqlite3, os

app = Flask(__name__, static_folder='static', static_url_path='')
DB = os.path.join(os.path.dirname(__file__), 'playground.db')

def db():
    conn = sqlite3.connect(DB)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    with db() as conn:
        conn.execute('''CREATE TABLE IF NOT EXISTS config (
            id      INTEGER PRIMARY KEY CHECK (id=1),
            parent1 TEXT NOT NULL,
            parent2 TEXT NOT NULL,
            kid1    TEXT NOT NULL,
            kid2    TEXT NOT NULL
        )''')
        conn.execute('''CREATE TABLE IF NOT EXISTS entries (
            id         INTEGER PRIMARY KEY AUTOINCREMENT,
            date       TEXT NOT NULL,
            shift      TEXT NOT NULL,
            user       TEXT NOT NULL,
            vacation   INTEGER DEFAULT 0,
            duration   TEXT,
            kids       TEXT,
            activities TEXT,
            excuse     TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )''')
        conn.execute('''CREATE TABLE IF NOT EXISTS tags (
            id   INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            name TEXT NOT NULL,
            UNIQUE(type, name)
        )''')

def get_cfg(conn):
    row = conn.execute('SELECT * FROM config LIMIT 1').fetchone()
    return dict(row) if row else None

@app.route('/')
def index():
    return app.send_static_file('index.html')

# ── Config ────────────────────────────────────────────────
@app.route('/api/config', methods=['GET'])
def api_config_get():
    with db() as conn:
        cfg = get_cfg(conn)
    return jsonify(cfg)

@app.route('/api/config', methods=['POST'])
def api_config_post():
    d = request.json
    with db() as conn:
        conn.execute('''INSERT INTO config (id,parent1,parent2,kid1,kid2)
                        VALUES (1,?,?,?,?)
                        ON CONFLICT(id) DO UPDATE SET
                        parent1=excluded.parent1, parent2=excluded.parent2,
                        kid1=excluded.kid1, kid2=excluded.kid2''',
                     (d['parent1'].strip(), d['parent2'].strip(),
                      d['kid1'].strip(),    d['kid2'].strip()))
    return '', 204

# ── Tags ──────────────────────────────────────────────────
@app.route('/api/tags', methods=['GET'])
def get_tags():
    t = request.args.get('type', '')
    with db() as conn:
        rows = conn.execute('SELECT name FROM tags WHERE type=? ORDER BY id', (t,)).fetchall()
    return jsonify([r['name'] for r in rows])

@app.route('/api/tags', methods=['POST'])
def add_tag():
    d = request.json
    with db() as conn:
        try:
            conn.execute('INSERT INTO tags (type,name) VALUES (?,?)', (d['type'], d['name'].strip()))
        except sqlite3.IntegrityError:
            pass
    return '', 204

# ── Entries ───────────────────────────────────────────────
@app.route('/api/entries', methods=['GET'])
def get_entries():
    date  = request.args.get('date')
    month = request.args.get('month')
    with db() as conn:
        if date:
            rows = conn.execute('SELECT * FROM entries WHERE date=? ORDER BY shift,id', (date,)).fetchall()
        elif month:
            rows = conn.execute('SELECT * FROM entries WHERE date LIKE ? ORDER BY date DESC,shift', (f'{month}%',)).fetchall()
        else:
            rows = conn.execute('SELECT * FROM entries ORDER BY date DESC,shift LIMIT 60').fetchall()
    return jsonify([dict(r) for r in rows])

@app.route('/api/entries', methods=['POST'])
def add_entry():
    d   = request.json
    vac = 1 if d.get('vacation') else 0
    excuse = None
    if not vac:
        raw = (d.get('excuse') or '').strip()
        excuse = raw if raw else None
    with db() as conn:
        cur = conn.execute(
            'INSERT INTO entries (date,shift,user,vacation,duration,kids,activities,excuse) VALUES (?,?,?,?,?,?,?,?)',
            (d['date'], d['shift'], d['user'], vac,
             None if vac else (d.get('duration') or None),
             None if vac else (d.get('kids') or None),
             None if vac else ((d.get('activities') or '').strip() or None),
             excuse)
        )
        row = conn.execute('SELECT * FROM entries WHERE id=?', (cur.lastrowid,)).fetchone()
    return jsonify(dict(row)), 201

@app.route('/api/entries/<int:eid>', methods=['DELETE'])
def del_entry(eid):
    with db() as conn:
        conn.execute('DELETE FROM entries WHERE id=?', (eid,))
    return '', 204

# ── Dashboard ─────────────────────────────────────────────
@app.route('/api/dashboard')
def dashboard():
    period = request.args.get('period', 'month')
    if period == 'week':
        start = request.args.get('start', '')
        end   = request.args.get('end', '')
        where, p = 'date >= ? AND date <= ?', (start, end)
    elif period == 'year':
        year  = request.args.get('year', '')
        where, p = 'date LIKE ?', (year + '%',)
    elif period == 'all':
        where, p = '1=1', ()
    else:
        month = request.args.get('month', '')
        where, p = 'date LIKE ?', (month + '%',)

    with db() as conn:
        cfg = get_cfg(conn)
        p1  = cfg['parent1'] if cfg else 'Parent 1'
        p2  = cfg['parent2'] if cfg else 'Parent 2'
        k1  = cfg['kid1']    if cfg else 'Kid 1'
        k2  = cfg['kid2']    if cfg else 'Kid 2'

        by_user = {}
        for name in [p1, p2]:
            cnt = conn.execute(
                f"SELECT COUNT(*) FROM entries WHERE {where} AND vacation=0 AND (user=? OR user='both')",
                p + (name,)
            ).fetchone()[0]
            by_user[name] = cnt

        kids_row = conn.execute(
            f'''SELECT SUM(CASE WHEN kids=? OR kids='both' THEN 1 ELSE 0 END) kid1,
                       SUM(CASE WHEN kids=? OR kids='both' THEN 1 ELSE 0 END) kid2
                FROM entries WHERE {where} AND vacation=0''', p + (k1, k2)
        ).fetchone()
        kids = dict(kids_row) if kids_row else {'kid1': 0, 'kid2': 0}

        shift_row = conn.execute(
            f"""SELECT SUM(CASE WHEN shift='morning' THEN 1 ELSE 0 END) morning,
                       SUM(CASE WHEN shift IN ('evening','afternoon') THEN 1 ELSE 0 END) evening
                FROM entries WHERE {where} AND vacation=0""", p
        ).fetchone()
        shifts = dict(shift_row) if shift_row else {'morning': 0, 'evening': 0}

        entries = [dict(r) for r in conn.execute(
            f'SELECT * FROM entries WHERE {where} ORDER BY date,shift', p
        ).fetchall()]

    return jsonify({'by_user': by_user, 'kids': kids, 'shifts': shifts, 'entries': entries})

if __name__ == '__main__':
    init_db()
    app.run(host='127.0.0.1', port=5000)
