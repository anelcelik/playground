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
        conn.execute('''CREATE TABLE IF NOT EXISTS entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL, shift TEXT NOT NULL, user TEXT NOT NULL,
            vacation INTEGER DEFAULT 0, no_outside INTEGER DEFAULT 0,
            duration TEXT, kids TEXT, activities TEXT,
            excuse TEXT, no_outside_reason TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )''')
        conn.execute('''CREATE TABLE IF NOT EXISTS tags (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL, name TEXT NOT NULL,
            UNIQUE(type, name)
        )''')
        try: conn.execute('ALTER TABLE entries ADD COLUMN excuse TEXT')
        except: pass
        try: conn.execute('ALTER TABLE entries ADD COLUMN no_outside INTEGER DEFAULT 0')
        except: pass
        try: conn.execute('ALTER TABLE entries ADD COLUMN no_outside_reason TEXT')
        except: pass
        try: conn.execute('ALTER TABLE entries ADD COLUMN no_activities INTEGER DEFAULT 0')
        except: pass
        try: conn.execute('ALTER TABLE entries ADD COLUMN no_activities_reason TEXT')
        except: pass

@app.route('/')
def index():
    return app.send_static_file('index.html')

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
    d = request.json
    vac = 1 if d.get('vacation') else 0
    no_out = 1 if d.get('no_outside') else 0
    skip = vac or no_out
    excuse = None
    no_out_reason = None
    if no_out:
        raw = (d.get('no_outside_reason') or '').strip()
        no_out_reason = raw if raw else None
    elif not vac:
        raw = (d.get('excuse') or '').strip()
        excuse = raw if raw else None
    with db() as conn:
        cur = conn.execute(
            'INSERT INTO entries (date,shift,user,vacation,no_outside,no_outside_reason,duration,kids,activities,excuse) VALUES (?,?,?,?,?,?,?,?,?,?)',
            (d['date'], d['shift'], d['user'], vac, no_out, no_out_reason,
             None if skip else (d.get('duration') or None),
             None if skip else (d.get('kids') or None),
             None if skip else ((d.get('activities') or '').strip() or None),
             excuse)
        )
        row = conn.execute('SELECT * FROM entries WHERE id=?', (cur.lastrowid,)).fetchone()
    return jsonify(dict(row)), 201

@app.route('/api/entries/<int:eid>', methods=['DELETE'])
def del_entry(eid):
    with db() as conn:
        conn.execute('DELETE FROM entries WHERE id=?', (eid,))
    return '', 204

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
        by_user = {}
        for name in ['Anel', 'Armina']:
            cnt = conn.execute(
                f"SELECT COUNT(*) FROM entries WHERE {where} AND vacation=0 AND no_outside=0 AND (user=? OR user='both')",
                p + (name,)
            ).fetchone()[0]
            by_user[name] = cnt
        kids_row = conn.execute(
            f'''SELECT SUM(CASE WHEN kids IN ("Una","both") THEN 1 ELSE 0 END) una,
                       SUM(CASE WHEN kids IN ("Dunja","both") THEN 1 ELSE 0 END) dunja
                FROM entries WHERE {where} AND vacation=0 AND no_outside=0''', p
        ).fetchone()
        kids = dict(kids_row) if kids_row else {'una': 0, 'dunja': 0}
        shift_row = conn.execute(
            f"""SELECT SUM(CASE WHEN shift='morning' THEN 1 ELSE 0 END) morning,
                       SUM(CASE WHEN shift IN ('evening','afternoon') THEN 1 ELSE 0 END) evening
                FROM entries WHERE {where} AND vacation=0 AND no_outside=0""", p
        ).fetchone()
        shifts = dict(shift_row) if shift_row else {'morning': 0, 'evening': 0}
        no_out_count = conn.execute(
            f"SELECT COUNT(DISTINCT date) FROM entries WHERE {where} AND no_outside=1", p
        ).fetchone()[0]
        entries = [dict(r) for r in conn.execute(
            f'SELECT * FROM entries WHERE {where} ORDER BY date,shift', p
        ).fetchall()]
    return jsonify({'by_user': by_user, 'kids': kids, 'shifts': shifts, 'no_outside': no_out_count, 'entries': entries})

if __name__ == '__main__':
    init_db()
    app.run(host='127.0.0.1', port=5000)
