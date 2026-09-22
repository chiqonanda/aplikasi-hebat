import io, re

files = [
    "lib/views/auth/register_view.dart",
    "lib/views/kelurahan/bank_sampah_list_view.dart",
    "lib/views/kelurahan/dashboard_kelurahan_view.dart",
    "lib/views/kelurahan/detail_bank_sampah_view.dart",
    "lib/views/kelurahan/master_sampah_view.dart",
    "lib/views/kelurahan/monitoring_view.dart",
    "lib/views/kelurahan/profil_kelurahan_view.dart",
    "lib/views/pengelola/dashboard_view.dart",
    "lib/views/pengelola/histori_view.dart",
    "lib/views/pengelola/input_sampah_view.dart",
    "lib/views/pengelola/laporan_pengelola_view.dart",
    "lib/views/pengelola/nasabah_list_view.dart",
    "lib/views/pengelola/profil_bank_sampah_view.dart",
]

# Blok dimulai di baris berisi "AnimatedWave" dan diakhiri baris yang hanya berisi ")"
block_re = re.compile(r"([ \t]*)AnimatedWave(?:\.(green|blue))?\(\n(.*?)\n[ \t]*\)", re.S)

def repl(m):
    indent, variant, body = m.group(1), m.group(2), m.group(3)
    # Ambil expr size (bisa multi-baris / mengandung koma dalam tanda kurung)
    size_m = re.search(r"size:\s*(.+?),\s*\n", body)
    size = size_m.group(1).strip()
    painter = ("WavePainter.%s()" % variant) if variant else None
    if painter is None:
        grad_m = re.search(r"gradient:\s*(.+?),\s*\n", body)
        overlay_m = re.search(r"overlayColor:\s*(.+?),\s*\n", body)
        painter = "WavePainter(gradient: %s, overlayColor: %s)" % (
            grad_m.group(1).strip(),
            overlay_m.group(1).strip(),
        )
    return (
        "%sCustomPaint(\n"
        "%s  size: %s,\n"
        "%s  painter: %s,\n"
        "%s)" % (indent, indent, size, indent, painter, indent)
    )

for p in files:
    src = io.open(p, encoding="utf-8").read()
    orig = src
    src = block_re.sub(repl, src)
    if src != orig:
        io.open(p, "w", encoding="utf-8", newline="").write(src)
        print("patched", p)
    else:
        print("NO MATCH", p)
