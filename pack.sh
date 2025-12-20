
#!/bin/sh
set -euo pipefail
LC_ALL='C'

mkdir -p ./tmp/

cp -f ./list/pack_adlist.txt ./tmp/rules01.txt

cd tmp

rules=(
  "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt"
  #"https://raw.githubusercontent.com/AdguardTeam/HostlistsRegistry/refs/heads/main/assets/filter_1.txt"
  "https://raw.githubusercontent.com/easylist/easylistchina/refs/heads/master/easylistchina.txt" #EasylistChina
  "https://raw.githubusercontent.com/easylist/easylist/refs/heads/gh-pages/easylist.txt" #Easylist
  "https://raw.githubusercontent.com/privacy-protection-tools/anti-AD/master/anti-ad-easylist.txt" #anti-AD
)

for i in "${!rules[@]}"; do
  url="${rules[$i]}"
  [ -z "$url" ] && continue
  curl -m 60 --retry-delay 2 --retry 5 --parallel --parallel-immediate -k -L -C - --connect-timeout 10 -s "$url" | iconv -t utf-8 > "rules${i}.txt" &
done

wait
echo "规则下载完成"

for f in $(ls *.txt | sort -u); do
  echo "" >> "$f" &
done
wait

echo "开始合并规则..."

cat rules*.txt \
  | grep -E '^(\|\||@@)' \
  | grep -Ev '^(#|!)' \
  | grep -Ev '^\|\|(\*\.?)?$' \
  | grep -Ev '^@@(\*\.?)?$' \
  | grep -Ev '^(\|\||@@)[0-9]+\.' \
  | grep -Ev '[*/$]' \
  | sed '/^$/d' \
  | awk '{
      key = $0;
      sub(/\^$/, "", key);
      if (!seen[key] || substr($0, length($0)) == "^") {
        seen[key] = $0;
      }
    }
    END {
      for (k in seen) print seen[k];
    }' \
  | sort -u > tmp-rules.txt

cp tmp-rules.txt ../list/pack_adlist.txt

echo "规则合并完成"

exit 0