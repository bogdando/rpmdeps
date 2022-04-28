#!/bin/bash
src=${1:-system-full-rpm.manifest}
curl -sfkL "$src" | awk -F'-[[:digit:]]' '{print $1}' > lv0

l=0
ld=0

while /bin/true; do
  lu=$((l+1))
  [ $l -ne 0 ] && ld=$((l-1))
  awk '{print $NF}' lv$l | sort -u | while read p; do [ -n "$(find . -name $p.lv${ld}_required_by)" ] && continue; rpm -q --whatrequires $p | awk -F'-[[:digit:]]' '{print $1}' > "$p.lv${lu}_required_by"; done
  grep -r ^ *lv${lu}_required_by | awk -F':' '!/no package/ {printf "%-40s\t%s\n", $1, $2}' | sort -k2 > lv${lu}
  cat lv${l} | while read p; do rpm -q --whatrequires $(echo $p | awk '{print $NF}') | awk '/no package/ {print $NF}'; done | sort -h | sort -u > direct${l}
  diff=$(comm -23 <(awk '{print $2}' lv${lu} |sort -u) <(awk '{print $2}' lv${l} |sort -u))
  [ -z "$diff" ] && break
  l=$((l+1))
done
