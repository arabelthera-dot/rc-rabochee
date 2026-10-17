#!/usr/bin/env bash
# Перенос рабочих (служебных) страниц из main rc-museum-preview в этот репозиторий.
# Мост до 19.10.2026: после переключения сайта на ветку site (18.10) инструменты ещё пишут
# в старый main; с переписыванием инструментов (план переезда, шаг 5) пишут сюда напрямую,
# а этот скрипт и конвейер perenos.yml удаляются.
set -euo pipefail
SRC=${SRC:-/tmp/rcmp-src}
DIRS="doska control review lab pult glazami opis-tools versions prototypes portal-next portal-atlas razbor-telefon plan dengi drafts tablo video calendar tests"
FILES="arhitektura-v2.html arhitektura-v2.1.html arhitektura-v2.2.html arhitektura-v2.3.html arhitektura-v2.4.html arhitektura-v2.5.html competitors.html control.html daily-report.html film.html game-3d-jump.html glavnaya-proto-0810.html handkerchief.html map.html karikatura/day-01jan-russian-bear.html karikatura/day-04jan-russian-bear.html karikatura/prototypes"
if [ ! -d "$SRC/.git" ]; then
  git clone -q --depth 1 --filter=blob:none --sparse https://github.com/arabelthera-dot/rc-museum-preview "$SRC"
fi
git -C "$SRC" sparse-checkout set --no-cone $(for d in $DIRS; do echo "/$d/"; done) $(for f in $FILES; do echo "/$f"; done)
git -C "$SRC" fetch -q --depth 1 origin main && git -C "$SRC" reset -q --hard origin/main
OUT=$(pwd)
for d in $DIRS; do rm -rf "$OUT/$d"; [ -e "$SRC/$d" ] && cp -r "$SRC/$d" "$OUT/$d"; done
for f in $FILES; do rm -rf "$OUT/$f"; [ -e "$SRC/$f" ] && mkdir -p "$OUT/$(dirname $f)" && cp -r "$SRC/$f" "$OUT/$f"; done
# Не витрина: запрет индексации в каждой странице, где его нет.
find $DIRS $FILES -name '*.html' 2>/dev/null | while read -r p; do
  grep -qi 'name="robots"' "$p" && continue
  if grep -qi '<head' "$p"; then sed -i '0,/<head[^>]*>/I s//&\n<meta name="robots" content="noindex,nofollow">/' "$p"
  else sed -i '1a <meta name="robots" content="noindex,nofollow">' "$p"; fi
done
