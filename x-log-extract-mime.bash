#!/bin/bash

INPUT="$1"
OUTDIR="allegati_estratti"
mkdir -p "$OUTDIR"

part_counter=0
declare -A name_count

in_base64=0
filename=""
mimetype=""
base64file=""

while IFS= read -r line || [ -n "$line" ]; do
  # Estrai filename
  if echo "$line" | grep -i "filename=" >/dev/null; then
    rawname=$(echo "$line" | sed -n 's/.*filename=["]*\([^";]*\).*/\1/p')
    filename="$rawname"
    continue
  fi

  # Estrai MIME type
  if echo "$line" | grep -i "^Content-Type:" >/dev/null; then
    mimetype=$(echo "$line" | sed -n 's/Content-Type:[ \t]*\([^;]*\).*/\1/p')
    continue
  fi

  # Inizio contenuto base64
  if echo "$line" | grep -i "Content-Transfer-Encoding: base64" >/dev/null; then
    in_base64=1
    part_counter=$((part_counter + 1))

    # Se filename non presente, usane uno automatico
    if [ -z "$filename" ]; then
      ext=$(echo "$mimetype" | tr '/' '-')
      filename="part-$(printf "%04d" $part_counter).$ext"
    fi

    # Se nome già esiste, aggiungi (1), (2), ...
    base="$filename"
    count="${name_count[$filename]}"
    if [ -n "$count" ]; then
      count=$((count + 1))
      name_count[$filename]=$count
      ext="${filename##*.}"
      name="${filename%.*}"
      filename="${name}($count).$ext"
    else
      name_count[$filename]=0
    fi

    base64file="$OUTDIR/$filename.base64"
    echo -n "" > "$base64file"
    continue
  fi

  # Salta riga vuota
  if [ "$in_base64" -eq 1 ] && [ -z "$line" ]; then
    continue
  fi

  # Raccoglie righe base64
  if [ "$in_base64" -eq 1 ]; then
    if echo "$line" | grep -Eq '^[A-Za-z0-9+/=]+$'; then
      echo "$line" >> "$base64file"
    else
      echo "✔ Salvato: $base64file"
      in_base64=0
      filename=""
      base64file=""
      mimetype=""
    fi
  fi

done < "$INPUT"
